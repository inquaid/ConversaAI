import io
import queue
import sys
import time
from dataclasses import dataclass
from typing import Optional, List, Tuple

import numpy as np
try:
    import sounddevice as sd  # type: ignore
except Exception:
    sd = None  # PortAudio not available; we'll error at runtime when needed
import soundfile as sf
import webrtcvad


SAMPLE_RATE = 16000  # 16 kHz mono for Whisper + VAD
SAMPLE_WIDTH = 2     # 16-bit PCM
CHANNELS = 1


def _rms(x: np.ndarray) -> float:
    return float(np.sqrt(np.mean(np.square(x.astype(np.float32) / 32768.0)) + 1e-9))


@dataclass
class AudioConfig:
    device_index: Optional[int] = None
    chunk_ms: int = 30          # VAD requires 10, 20, or 30 ms
    silence_ms: int = 600       # end record after this much silence
    vad_aggressiveness: int = 2 # 0-3
    ptt: bool = False           # push-to-talk mode


class MicRecorder:
    def __init__(self, cfg: AudioConfig):
        if cfg.chunk_ms not in (10, 20, 30):
            raise ValueError("chunk_ms must be 10, 20, or 30 for WebRTC VAD")
        self.cfg = cfg
        self.block_size = int(SAMPLE_RATE * cfg.chunk_ms / 1000)
        self.stream = None
        self.vad = webrtcvad.Vad(cfg.vad_aggressiveness)
        self.q = queue.Queue()

    def _callback(self, indata, frames, time_, status):
        if status:
            print(f"[audio] {status}", file=sys.stderr)
        mono = indata[:, 0]
        pcm16 = (np.clip(mono, -1.0, 1.0) * 32767).astype(np.int16)
        self.q.put(pcm16)

    def __enter__(self):
        if sd is None:
            raise RuntimeError(
                "sounddevice/PortAudio not available. Install system package 'portaudio' (e.g., 'sudo apt-get install portaudio19-dev') and reinstall the Python package 'sounddevice'."
            )
        self.stream = sd.InputStream(
            samplerate=SAMPLE_RATE,
            channels=CHANNELS,
            dtype='float32',
            blocksize=self.block_size,
            callback=self._callback,
            device=self.cfg.device_index,
        )
        self.stream.start()
        return self

    def __exit__(self, exc_type, exc, tb):
        if self.stream is not None:
            try:
                self.stream.stop()
                self.stream.close()
            except Exception:
                pass
        self.stream = None

    def record_once(self) -> np.ndarray:
        """Record a single utterance using VAD or push-to-talk.
        Returns int16 mono PCM at 16kHz.
        """
        frames: List[np.ndarray] = []
        voiced = False
        silence_start: Optional[float] = None

        chunk_dur = self.cfg.chunk_ms / 1000.0
        silence_thresh = self.cfg.silence_ms / 1000.0

        print("Listening… (Ctrl+C to quit)")
        try:
            if self.cfg.ptt:
                print("Push-to-talk: hold SPACE to record, release to stop.")
                # Simple PTT via keyboard input isn’t trivial cross-platform. Fallback to time-based capture.
                # Capture until a brief silence window after initial speech.
            while True:
                pcm16 = self.q.get()
                is_speech = self.vad.is_speech(pcm16.tobytes(), SAMPLE_RATE)
                if is_speech:
                    frames.append(pcm16)
                    voiced = True
                    silence_start = None
                else:
                    if voiced:
                        frames.append(pcm16)
                        if silence_start is None:
                            silence_start = time.time()
                        elif time.time() - silence_start >= silence_thresh:
                            break
                    else:
                        # Wait for speech to start, but keep small buffer
                        frames.append(pcm16)
                        # Trim buffer to 1s max
                        max_buf = int(1.0 / chunk_dur)
                        if len(frames) > max_buf:
                            frames = frames[-max_buf:]
        except KeyboardInterrupt:
            pass

        if not frames:
            return np.zeros((0,), dtype=np.int16)
        audio = np.concatenate(frames)
        # Trim leading/trailing low RMS segments lightly (no-op for now)
        rms = _rms(audio)
        if rms < 1e-3:
            return audio
        return audio


def write_wav(path: str, pcm16: np.ndarray, samplerate: int = SAMPLE_RATE):
    sf.write(path, pcm16.astype(np.int16), samplerate, subtype='PCM_16')


def pcm16_to_wav_bytes(pcm16: np.ndarray, samplerate: int = SAMPLE_RATE) -> bytes:
    with io.BytesIO() as buf:
        sf.write(buf, pcm16.astype(np.int16), samplerate, subtype='PCM_16', format='WAV')
        return buf.getvalue()


def list_input_devices() -> List[Tuple[int, str]]:
    if sd is None:
        return []
    devices = sd.query_devices()
    res: List[Tuple[int, str]] = []
    for idx, dev in enumerate(devices):
        if dev.get('max_input_channels', 0) > 0:
            res.append((idx, dev.get('name', f'device-{idx}')))
    return res
