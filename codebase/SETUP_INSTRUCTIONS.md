# ConversaAI Setup Instructions

## 🔧 Prerequisites

### 1. System Dependencies (Linux)
```bash
sudo apt-get update
sudo apt-get install -y ffmpeg portaudio19-dev python3-pip python3-venv
```

### 2. Python Backend Setup
```bash
cd /home/turjo-pop/Documents/ConversaAI/codebase/lib/backend/voice_backend
python3 -m pip install -r requirements.txt
```

### 3. Flutter Dependencies
```bash
cd /home/turjo-pop/Documents/ConversaAI/codebase
flutter pub get
```

## 🔑 API Keys (Optional but Recommended)

### Gemini API Key (for Enhanced AI Responses)
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Set the environment variable:
```bash
export GEMINI_API_KEY="your_api_key_here"
```

### Alternative: Use without API Key
- The app will work with basic local responses if no Gemini API key is provided
- Set the key in your shell profile for permanent use:
```bash
echo 'export GEMINI_API_KEY="your_api_key_here"' >> ~/.bashrc
source ~/.bashrc
```

## 🚀 Running the App

### Terminal 1: Start Flutter App
```bash
cd /home/turjo-pop/Documents/ConversaAI/codebase
export GEMINI_API_KEY="your_api_key_here"  # if you have one
flutter run -d linux
```

## 📱 How to Use

1. **Start Recording**: Press the microphone button to start recording your voice
2. **Stop Recording**: Press the microphone button again to stop recording
3. **Processing**: The app will transcribe your speech and generate an AI response
4. **Response**: You'll see both your transcribed text and the AI's reply

## 🔍 Troubleshooting

### Audio Permission Issues
```bash
# Check microphone permissions
pactl list sources short
# Restart PulseAudio if needed
systemctl --user restart pulseaudio
```

### Backend Issues
```bash
# Test backend manually
cd lib/backend/voice_backend
python3 -c "from single_turn import SingleTurnEngine, SingleTurnConfig; engine = SingleTurnEngine(SingleTurnConfig()); print(engine.respond('test'))"
```

### Flutter Build Issues
```bash
flutter clean
flutter pub get
flutter run -d linux
```

## 📊 System Requirements

- **RAM**: 4GB minimum (8GB recommended for Whisper models)
- **Storage**: 2GB free space for AI models
- **Audio**: Working microphone and speakers
- **OS**: Linux (Ubuntu 18.04+ recommended)

## 🎯 Features

- ✅ Real-time voice recording (16kHz WAV)
- ✅ Speech-to-text via OpenAI Whisper
- ✅ AI responses via Google Gemini (optional) or local fallback
- ✅ Clean Flutter UI with conversation history
- ✅ Audio visualization during recording
- ⏳ Text-to-speech playback (planned)

## 🔮 Next Steps

1. **Add TTS Playback**: Implement audio playback of AI responses
2. **Streaming**: Add real-time transcription
3. **Voice Training**: Add pronunciation feedback
4. **Multi-language**: Support multiple languages

---

**Note**: First run will download Whisper models (~150MB for base model). This is normal and only happens once.
