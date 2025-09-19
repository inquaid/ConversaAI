# Voice Backend (renamed)

This directory hosts the conversational Python backend previously located at `lib/prac/conversaai`.
The old path is deprecated; future integrations should import & execute code here.

Core components (copied from original):
- `engine.py` main orchestration (capture → transcribe → respond → synthesize)
- `asr.py` Whisper-based speech recognition
- `llm.py` optional Gemini large language model responder
- `nlp.py` lightweight feedback generator fallback
- `tts.py` gTTS speech synthesis
- `audio.py` microphone capture & VAD utilities

A lightweight Dart bridge will spawn a Python process invoking `engine_invoke.py` (to be added) for a single-turn reply.
