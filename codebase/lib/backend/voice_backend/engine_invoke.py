#!/usr/bin/env python3
"""Helper script to perform a single turn (transcribe+reply) for a given WAV file.
Prints JSON {"transcript": str, "reply": str} to stdout.
"""
import json, sys, os, tempfile
try:
    from .single_turn import SingleTurnEngine, SingleTurnConfig
except ImportError:
    # Fallback for direct execution
    from single_turn import SingleTurnEngine, SingleTurnConfig

try:
    wav_path = sys.argv[1]
except IndexError:
    print("Usage: engine_invoke.py <wav_path>", file=sys.stderr)
    sys.exit(2)

if not os.path.isfile(wav_path):
    print("File not found", file=sys.stderr)
    sys.exit(3)

try:
    engine = SingleTurnEngine(SingleTurnConfig())
    text = engine.transcribe(wav_path)
    reply = engine.respond(text)
    json.dump({"transcript": text, "reply": reply}, sys.stdout)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    json.dump({"transcript": "", "reply": f"Error: {e}"}, sys.stdout)
    sys.exit(1)
