from dataclasses import dataclass
from typing import List, Optional


PERSONA_PROMPT = (
    "You are an interactive English-speaking companion. "
    "Your main goal is to help the user practice English speaking fluency. "
    "Always respond in a conversational, natural, and engaging way. "
    "Don’t just answer—also ask relevant follow-up questions so the conversation flows naturally and lasts longer. "
    "Adjust your tone to be friendly and supportive, like a human speaking partner. "
    "If the user makes mistakes, gently correct grammar, word choice, or phrasing, but keep the flow natural. "
    "Encourage the user to explain thoughts, share stories, or express opinions. "
    "Sometimes introduce new words or phrases, explain their meaning, and encourage the user to use them. "
    "Keep replies short enough for spoken interaction (2–5 sentences), not long essays."
)


@dataclass
class GeminiConfig:
    # model: str = "gemini-1.5-flash"
    model: str = "gemini-2.5-flash"
    api_key: Optional[str] = None


class GeminiResponder:
    def __init__(self, cfg: GeminiConfig):
        # Lazy import to avoid hard dependency when not used
        try:
            import google.generativeai as genai  # type: ignore
        except Exception as e:
            raise RuntimeError("google-generativeai is not installed.") from e
        if not cfg.api_key:
            raise RuntimeError("GENAI API key not provided.")
        genai.configure(api_key=cfg.api_key)
        self._genai = genai
        self._model = genai.GenerativeModel(cfg.model)

    def reply(self, history: List[dict], user_text: str) -> str:
        # history: list of {role: "user"|"assistant", content: str}
        messages = [
            {"role": "user", "parts": PERSONA_PROMPT},
        ]
        for turn in history[-6:]:  # keep it short
            role = "user" if turn.get("role") == "user" else "model"
            messages.append({"role": role, "parts": turn.get("content", "")})
        messages.append({"role": "user", "parts": user_text})

        resp = self._model.generate_content(messages)
        # google-generativeai returns .text
        text = getattr(resp, "text", "").strip()
        # print(text)
        text = text.replace("*", "")
        return text or "Could you tell me a bit more?"
