import re
from dataclasses import dataclass


@dataclass
class Feedback:
    reply: str
    tips: list[str]


def simple_feedback(user_text: str) -> Feedback:
    text = user_text.strip()
    tips: list[str] = []

    # basic suggestions
    if not text:
        return Feedback(reply="I didn't catch anything. Could you say that again?", tips=[])

    # Capitalize I when used as pronoun
    fixed = re.sub(r"\b(i)\b", "I", text, flags=re.IGNORECASE)

    # Encourage longer sentences
    if len(text.split()) < 4:
        tips.append("Try speaking in a full sentence to practice structure.")

    # Suggest past tense if yesterday appears
    if re.search(r"yesterday", text, re.IGNORECASE):
        tips.append("When talking about the past, ensure verbs are in past tense.")

    # Common contractions suggestion
    if re.search(r"do not|can not|will not", text, re.IGNORECASE):
        tips.append("Try using contractions like don't, can't, won't in casual speech.")

    # Build reply
    reply = f"You said: ‘{fixed}’. Nice! "
    if tips:
        reply += "Here's a tip: " + tips[0]
    else:
        reply += "Tell me more about that."

    return Feedback(reply=reply, tips=tips)
