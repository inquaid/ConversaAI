from dataclasses import dataclass
from typing import Optional

import numpy as np
import whisper
import torch


@dataclass
class ASRConfig:
    model_name: str = "base"  # tiny|base|small|medium|large-v2
    language: Optional[str] = "en"
    device: str = "auto"  # 'auto' | 'cpu' | 'cuda' | 'gpu'


class WhisperASR:
    def __init__(self, cfg: ASRConfig):
        self.cfg = cfg
        # Resolve device
        want = (cfg.device or "auto").lower()
        if want in ("cuda", "gpu") and torch.cuda.is_available():
            device = "cuda"
        elif want == "auto":
            device = "cuda" if torch.cuda.is_available() else "cpu"
        else:
            device = "cpu"

        # Enable GPU-friendly settings
        if device == "cuda":
            torch.backends.cuda.matmul.allow_tf32 = True  # TensorFloat32 for speed
            torch.backends.cudnn.allow_tf32 = True
            torch.backends.cudnn.benchmark = True
            try:
                torch.set_float32_matmul_precision("high")
            except Exception:
                pass

        self.device = device
        self.model = whisper.load_model(cfg.model_name, device=device)

    def transcribe(self, wav_path: str) -> str:
        # Use fp16 on CUDA for speed
        use_fp16 = (self.device == "cuda")
        result = self.model.transcribe(
            wav_path,
            language=self.cfg.language,
            fp16=use_fp16,
        )
        return result.get("text", "").strip()
