# Single-turn engine for Flutter integration
import os
import sys
from dataclasses import dataclass
from typing import Optional

try:
    from .asr import ASRConfig, WhisperASR
    from .llm import GeminiResponder, GeminiConfig
    from .nlp import simple_feedback
    from .tts import GTTSVoice, TTSConfig
except ImportError:
    # Fallback for direct execution
    from asr import ASRConfig, WhisperASR
    from llm import GeminiResponder, GeminiConfig
    from nlp import simple_feedback
    from tts import GTTSVoice, TTSConfig

@dataclass
class SingleTurnConfig:
    model_name: str = "base"
    language: Optional[str] = "en"
    device: str = "auto"
    tts_lang: str = "en"
    tts_slow: bool = False

class SingleTurnEngine:
    def __init__(self, cfg: SingleTurnConfig):
        self.cfg = cfg
        self.asr = WhisperASR(ASRConfig(model_name=cfg.model_name, language=cfg.language, device=cfg.device))
        self.voice = GTTSVoice(TTSConfig(lang=cfg.tts_lang, slow=cfg.tts_slow))
        self.history: list[dict] = []
        self.gemini: GeminiResponder | None = None
        api_key = os.getenv("GEMINI_API_KEY")
        if api_key:
            try:
                self.gemini = GeminiResponder(GeminiConfig(api_key=api_key))
                print("Gemini responder enabled.", file=sys.stderr)
            except Exception as e:
                print(f"Gemini disabled: {e}", file=sys.stderr)

    def transcribe(self, wav_path: str) -> str:
        return self.asr.transcribe(wav_path)

    def respond(self, user_text: str) -> str:
        if not user_text.strip():
            return "I didn't catch anything. Could you repeat?"
        reply = None
        if self.gemini:
            try:
                reply = self.gemini.reply(self.history, user_text)
            except Exception as e:
                print(f"Gemini error: {e}", file=sys.stderr)
                reply = None
        if reply is None:
            fb = simple_feedback(user_text)
            reply = fb.reply
        self.history.append({"role": "user", "content": user_text})
        self.history.append({"role": "assistant", "content": reply})
        return reply
