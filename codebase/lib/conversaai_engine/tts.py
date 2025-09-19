from dataclasses import dataclass
from typing import Optional

from gtts import gTTS


@dataclass
class TTSConfig:
    lang: str = "en"
    slow: bool = False


class GTTSVoice:
    def __init__(self, cfg: TTSConfig):
        self.cfg = cfg

    def synthesize_to_file(self, text: str, out_path: str):
        tts = gTTS(text=text, lang=self.cfg.lang, slow=self.cfg.slow)
        tts.save(out_path)
        return out_path
