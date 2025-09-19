import os
import tempfile
import time
from dataclasses import dataclass
from typing import Optional

from .asr import ASRConfig, WhisperASR
from .audio import AudioConfig, MicRecorder, write_wav
from .nlp import simple_feedback
from .llm import GeminiResponder, GeminiConfig
from .tts import GTTSVoice, TTSConfig


@dataclass
class EngineConfig:
    # audio
    device_index: Optional[int] = None
    chunk_ms: int = 30
    silence_ms: int = 700
    vad_aggressiveness: int = 2
    ptt: bool = False
    # asr
    model_name: str = "base"
    language: Optional[str] = "en"
    device: str = "auto"
    # tts
    tts_lang: str = "en"
    tts_slow: bool = False


class ConversaEngine:
    def __init__(self, cfg: EngineConfig):
        self.cfg = cfg
        self.asr = WhisperASR(ASRConfig(model_name=cfg.model_name, language=cfg.language, device=cfg.device))
        self.voice = GTTSVoice(TTSConfig(lang=cfg.tts_lang, slow=cfg.tts_slow))
        self.audio_cfg = AudioConfig(
            device_index=cfg.device_index,
            chunk_ms=cfg.chunk_ms,
            silence_ms=cfg.silence_ms,
            vad_aggressiveness=cfg.vad_aggressiveness,
            ptt=cfg.ptt,
        )
        self.history: list[dict] = []
        # Optional Gemini
        self.gemini: GeminiResponder | None = None
        api_key = os.getenv("GEMINI_API_KEY")
        if api_key:
            try:
                self.gemini = GeminiResponder(GeminiConfig(api_key=api_key))
                print("Gemini responder enabled.")
            except Exception as e:
                print(f"Gemini disabled: {e}")
        # Optional warm-up step to reduce first token latency on GPU
        try:
            import torch
            if torch.cuda.is_available():
                torch.cuda.synchronize()
        except Exception:
            pass

    def run_once(self) -> bool:
        """Capture one utterance, transcribe, respond, and speak. Returns False to stop."""
        with MicRecorder(self.audio_cfg) as mic:
            pcm16 = mic.record_once()
        if pcm16.size == 0:
            print("No audio captured.")
            return True

        with tempfile.TemporaryDirectory() as td:
            wav_path = os.path.join(td, "input.wav")
            write_wav(wav_path, pcm16)
            text = self.asr.transcribe(wav_path)

        if not text:
            print("I couldn't understand that. Let's try again.")
            return True

        fb = None
        if self.gemini:
            try:
                llm_reply = self.gemini.reply(self.history, text)
                fb = type("FB", (), {"reply": llm_reply, "tips": []})
            except Exception as e:
                print(f"Gemini error: {e}. Falling back to local feedback.")
        if fb is None:
            fb = simple_feedback(text)
        print(f"User: {text}")
        print(f"Assistant: {fb.reply}")
        # Update history for context
        self.history.append({"role": "user", "content": text})
        self.history.append({"role": "assistant", "content": fb.reply})

        # Append to transcript log
        log_path = os.path.join(os.getcwd(), "transcript.log")
        try:
            with open(log_path, "a", encoding="utf-8") as logf:
                logf.write(f"USER\t{text}\n")
                logf.write(f"ASSISTANT\t{fb.reply}\n")
        except Exception:
            pass

        # Synthesize to MP3 and attempt playback via ffplay (FFmpeg)
        out_mp3 = os.path.join(os.getcwd(), "reply.mp3")
        self.voice.synthesize_to_file(fb.reply, out_mp3)
        print(f"Spoken reply saved to {out_mp3}")
        try:
            import subprocess
            subprocess.run([
                "ffplay", "-nodisp", "-autoexit", "-loglevel", "error", out_mp3
            ], check=False)
        except FileNotFoundError:
            print("Note: ffplay not found. Install FFmpeg to auto-play replies.")
        return True
