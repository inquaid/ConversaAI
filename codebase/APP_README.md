# ConversaAI - English Learning Voice Assistant

ConversaAI is a modern Flutter desktop application designed to help users learn and improve their English through natural, real-time voice conversations. The app provides an immersive, AI-powered language learning experience with beautiful animations and intuitive voice controls.

## Features

### 🎙️ Voice-First Interface
- **Interactive Voice Chat**: Tap to speak, AI responds naturally
- **Real-time Voice Visualization**: Dynamic waveforms and animations during conversations
- **Multi-state Interface**: Clear visual feedback for listening, speaking, processing, and idle states

### 🎨 Modern Design
- **Beautiful Animations**: Inspired by Siri, Google Assistant, and ChatGPT voice modes
- **Dual Themes**: Elegant light and dark modes with smooth transitions
- **Voice Visualizations**: Real-time waveforms, pulsating microphone, and animated backgrounds
- **Material You Design**: Following Google's latest design principles

### 🌟 Key UI Components
1. **Animated Microphone Button**: Central interaction point with state-based colors and animations
2. **Voice Visualizer**: Dynamic waveforms and visual feedback during voice interactions
3. **Conversation Feedback**: Clean message bubbles and status indicators
4. **Responsive Layout**: Optimized for desktop with proper spacing and proportions

## Technical Architecture

### State Management
- **Provider Pattern**: Clean separation of business logic and UI
- **VoiceProvider**: Manages voice interaction states (idle, listening, speaking, processing, error)
- **ThemeProvider**: Handles theme switching and persistence

### Animation System
- **Flutter's Animation Framework**: Smooth, performant animations
- **Custom Painters**: Hand-crafted waveform visualizations
- **Ticker Providers**: Precise animation timing and control

### Supported Platforms
- ✅ **Linux** (Primary development platform)
- ✅ **Windows** (Ready for deployment)
- ✅ **macOS** (Ready for deployment)

## Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Platform-specific requirements for desktop development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/inquaid/ConversaAI.git
   cd ConversaAI/codebase
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For Linux
   flutter run -d linux
   
   # For Windows
   flutter run -d windows
   
   # For macOS
   flutter run -d macos
   ```

## Usage Guide

### Basic Interaction
1. **Launch the app** - You'll see the ConversaAI interface with a microphone button
2. **Tap the microphone** - Start speaking when the interface shows "I'm listening..."
3. **Speak naturally** - The app visualizes your voice with animated waveforms
4. **Tap again to stop** - Or the app will automatically process your speech
5. **Receive feedback** - AI responds with voice and visual feedback

### Interface States
- **🟢 Idle**: Ready to start conversation (blue microphone)
- **🔵 Listening**: Recording your voice (animated blue waveforms)
- **🟠 Processing**: Analyzing your speech (pulsating orange icon)
- **🟢 Speaking**: AI is responding (green waveforms)
- **🔴 Error**: Something went wrong (red icon, tap to retry)

### Theme Switching
- Use the theme toggle button in the top-right corner
- Seamless transition between light and dark modes
- Voice visualizations adapt to the current theme

## Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── providers/               # State management
│   ├── voice_provider.dart   # Voice interaction logic
│   └── theme_provider.dart   # Theme management
├── screens/                 # Main app screens
│   └── home_screen.dart      # Primary interface
└── widgets/                 # Reusable UI components
    ├── app_header.dart       # Top navigation bar
    ├── conversation_feedback.dart  # Message display
    ├── voice_interface.dart  # Main microphone interface
    ├── voice_visualizer.dart # Waveform animations
    └── animated_widgets.dart # Custom animations
```

## Dependencies

### Core Packages
- `flutter`: Framework
- `provider`: State management
- `google_fonts`: Typography

### UI & Animation
- `lottie`: Advanced animations (ready for future use)
- `animated_text_kit`: Text animations
- `flutter_svg`: Vector graphics support

### Future Backend Integration
- `http` & `dio`: API communication
- `shared_preferences`: Local storage
- Audio packages (commented out for Linux compatibility)

## Design Philosophy

ConversaAI follows modern voice UI best practices:

1. **Voice and Visuals in Harmony**: Visual feedback enhances voice interactions
2. **Immediate Feedback**: Users always know the app's current state
3. **Minimal Interface**: Clean, uncluttered design focused on conversation
4. **Responsive Animations**: Smooth, purposeful motion that feels alive
5. **Error Forgiveness**: Gentle error handling with clear recovery paths

## Color Palette

### Light Theme
- Primary: iOS Blue (#007AFF)
- Background: Clean whites and subtle grays
- Accents: Green for speaking, orange for processing

### Dark Theme
- Primary: iOS Blue Dark (#0A84FF)
- Background: Rich blacks and dark grays (#1C1C1E, #2C2C2E)
- Accents: Vibrant colors that pop against dark backgrounds

## Future Enhancements

- 🔊 **Real Audio Integration**: Connect to speech recognition and TTS services
- 🧠 **AI Backend**: Integrate with language learning AI models
- 📊 **Progress Tracking**: User learning analytics and progress visualization
- 🌍 **Multi-language Support**: Expand beyond English learning
- 📱 **Mobile Versions**: iOS and Android adaptations
- 🎯 **Learning Features**: Grammar correction, vocabulary suggestions, pronunciation feedback

## Contributing

We welcome contributions! Please see our contributing guidelines for more details.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by Siri, Google Assistant, and ChatGPT voice interfaces
- Built with Flutter's powerful animation and rendering capabilities
- Design principles from Material You and modern voice UI guidelines
