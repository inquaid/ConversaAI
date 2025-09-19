import argparse

from .engine import ConversaEngine, EngineConfig


def main():
    p = argparse.ArgumentParser(description="ConversaAI backend (CLI)")
    p.add_argument('--device-index', type=int, default=None)
    p.add_argument('--chunk-ms', type=int, default=30)
    p.add_argument('--silence-ms', type=int, default=700)
    p.add_argument('--vad', type=int, default=2, choices=[0,1,2,3], help='VAD aggressiveness')
    p.add_argument('--ptt', action='store_true', help='push-to-talk mode (simplified)')
    p.add_argument('--model', default='base')
    p.add_argument('--language', default='en')
    p.add_argument('--device', default='auto')
    p.add_argument('--tts-lang', default='en')
    p.add_argument('--tts-slow', action='store_true')
    p.add_argument('--input-wav', default=None, help='process an existing WAV file instead of recording')
    p.add_argument('--use-gemini', action='store_true', help='use Gemini LLM for replies')
    p.add_argument('--gemini-api-key', default=None, help='Gemini API key (overrides GEMINI_API_KEY env)')
    args = p.parse_args()

    cfg = EngineConfig(
        device_index=args.device_index,
        chunk_ms=args.chunk_ms,
        silence_ms=args.silence_ms,
        vad_aggressiveness=args.vad,
        ptt=args.ptt,
        model_name=args.model,
        language=args.language,
        device=args.device,
        tts_lang=args.tts_lang,
        tts_slow=args.tts_slow,
    )

    # Pass API key via env for engine path
    if args.use_gemini and args.gemini_api_key:
        import os as _os
        _os.environ["GEMINI_API_KEY"] = args.gemini_api_key
    engine = ConversaEngine(cfg)
    if args.input_wav:
        # One-shot: bypass mic, transcribe file and speak reply
        from .asr import WhisperASR, ASRConfig
        from .nlp import simple_feedback
        from .tts import GTTSVoice, TTSConfig
        from .llm import GeminiResponder, GeminiConfig
        asr = WhisperASR(ASRConfig(model_name=args.model, language=args.language, device=args.device))
        text = asr.transcribe(args.input_wav)
        print(f"User (file): {text}")
        reply_text = None
        if args.use_gemini:
            key = args.gemini_api_key or __import__('os').environ.get('GEMINI_API_KEY')
            if key:
                try:
                    gem = GeminiResponder(GeminiConfig(api_key=key))
                    reply_text = gem.reply([], text)
                except Exception as e:
                    print(f"Gemini error: {e}. Falling back to local feedback.")
        if not reply_text:
            fb = simple_feedback(text)
            reply_text = fb.reply
        print(f"Assistant: {reply_text}")
        voice = GTTSVoice(TTSConfig(lang=args.tts_lang, slow=args.tts_slow))
        out_mp3 = "reply.mp3"
        voice.synthesize_to_file(reply_text, out_mp3)
        print(f"Spoken reply saved to {out_mp3}")
    else:
        print("ConversaAI started. Speak after the prompt.")
        while True:
            cont = engine.run_once()
            if not cont:
                break


if __name__ == '__main__':
    main()
