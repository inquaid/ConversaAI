# ConversaAI Backend (CLI)

A minimal backend engine for real-time English conversation practice.
- Speech-to-Text (STT): OpenAI Whisper
- Text-to-Speech (TTS): gTTS
- Voice Activity Detection (VAD): WebRTC VAD
- Audio I/O: sounddevice + soundfile

No UI. Runs in terminal, listens for speech, transcribes, generates feedback, and speaks the reply.

## Features
- Push-to-talk or auto VAD capture (configurable)
- Continuous loop: listen → transcribe → respond → speak
- Instant grammar/style feedback with suggestions
- Session transcript log

## Quick start

Prereqs: Python 3.9+, FFmpeg (ffmpeg/ffplay) and PortAudio runtime installed on your system. For GPU acceleration, install CUDA + cuDNN compatible with your PyTorch build.

1. Create venv and install dependencies

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Run the CLI

```bash
export GEMINI_API_KEY="AIzaSyBdQ5cHwQCUaTvr8qywxBxEHFyT1rETWYQ"
echo $GEMINI_API_KEY
python -m conversaai
```

Optional flags:
- `--device-index N` choose audio input device index
- `--language en` set expected language for Whisper
- `--model small` one of tiny|base|small|medium|large-v2
- `--ptt` enable push-to-talk (hold space to record)
 - `--silence-ms` adjust end-of-utterance silence (default 700)
 - `--chunk-ms` VAD frame size (10/20/30; default 30)
 - `--use-gemini` enable Gemini LLM replies (optional)
 - `--gemini-api-key` set the Gemini API key (or use env GEMINI_API_KEY)
 - `--device auto|cuda|cpu` set compute device (default auto). On a CUDA GPU the app uses FP16 and CuDNN for speed.

3. Troubleshooting
- Install system deps (Ubuntu/Debian):
```bash
sudo apt-get update
sudo apt-get install -y ffmpeg portaudio19-dev
```
- If no microphone is detected, list devices:
```bash
python -m conversaai.list_devices
```
- If audio is choppy, increase `--chunk-ms` or `--silence-ms`.
- If Whisper complains about FFmpeg, install it via your OS package manager.
 - To enable Gemini replies, provide an API key (env `GEMINI_API_KEY` or `--gemini-api-key`).
 - To force GPU: add `--device cuda`; to force CPU: `--device cpu`.

## Project layout
- `conversaai/__main__.py` entry point
- `conversaai/asr.py` Whisper transcription
- `conversaai/tts.py` gTTS synthesis
- `conversaai/audio.py` mic capture, VAD, WAV I/O
- `conversaai/nlp.py` feedback logic
- `conversaai/engine.py` conversation loop
- `conversaai/list_devices.py` device lister
 - `conversaai/llm.py` optional Gemini-based responder and persona

## Notes
- gTTS requires internet to synthesize speech.
- Whisper models download on first run; pick a smaller model if RAM/CPU is limited.
 - Replies are saved to `reply.mp3` and auto-played with `ffplay` if available.
 - Gemini is optional; when enabled, replies follow the English-speaking companion persona and include follow-up questions and gentle corrections.
