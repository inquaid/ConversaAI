# ConversaAI - English Learning through Conversation

ConversaAI is a cross-platform Flutter application that helps users learn and improve their English through natural, real-time conversations with AI. The app features a clean, minimal design with interactive animations for speaking and listening modes.

## 📱 Features

- **Splash Screen**: Animated intro with ConversaAI branding
- **Home Screen**: Clean welcome interface with easy navigation
- **Speaking Mode**: Interactive speaking interface with real-time audio visualization
- **Listening Mode**: Animated listening interface showing AI responses
- **State Management**: Comprehensive conversation state handling
- **Modern UI**: Material Design 3 with consistent typography and spacing
- **Responsive Design**: Works across mobile, tablet, and desktop platforms

## 🏗️ Architecture

The project follows a clean, modular architecture:

```
lib/
├── core/                     # Core app configuration
│   ├── constants/           # App colors, dimensions, durations
│   ├── theme/              # Material theme configuration
│   └── utils/              # Utility functions and extensions
├── features/               # Feature-based modules
│   ├── splash/            # Splash screen
│   ├── home/              # Home screen
│   └── conversation/      # Main conversation interface
│       └── widgets/       # Conversation-specific widgets
├── shared/                # Shared components
│   ├── providers/         # State management (Provider)
│   └── widgets/           # Reusable UI components
└── data/                  # Data layer (prepared for backend)
    ├── models/            # Data models
    ├── services/          # API and external services
    └── repositories/      # Data access layer
```

## 🎨 Design System

### Colors
- **Primary**: Blue (#2196F3) - Main brand color
- **Secondary**: Green (#4CAF50) - Success and speaking states
- **Background**: Light gray (#FAFAFA) - Clean background
- **Text**: Dark gray (#212121) - High contrast readability

### Typography
- **Font**: Inter (via Google Fonts)
- **Hierarchy**: Consistent text scaling from 10px to 32px
- **Weights**: 400, 500, 600, and bold for emphasis

### Animations
- **Speaking**: Pulsing microphone with sound wave visualization
- **Listening**: Rotating icon with ripple effects
- **Transitions**: Smooth 300ms transitions between states

## 🔧 Backend Integration Ready

The app is structured for easy backend integration:

### Placeholder Services
- `AIConversationService`: Ready for AI API integration
- `SpeechToTextService`: Speech recognition placeholder
- `TextToSpeechService`: Voice synthesis placeholder
- `ConversationRepository`: Data management layer

### Models
- `ConversationMessage`: Message structure
- `ConversationSession`: Session management
- `UserProfile`: User data handling

## 🚀 Getting Started

### Prerequisites
- Flutter 3.8.1 or higher
- Dart 3.0 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd conversa_ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For web
   flutter run -d chrome
   
   # For mobile (with device/emulator connected)
   flutter run
   
   # For desktop
   flutter run -d windows  # or macos, linux
   ```

### Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📁 Key Files

### Core Configuration
- `lib/main.dart` - App entry point with provider setup
- `lib/core/theme/app_theme.dart` - Complete Material theme
- `lib/core/constants/app_constants.dart` - Design tokens

### State Management
- `lib/shared/providers/app_state_provider.dart` - Main app state

### UI Screens
- `lib/features/splash/splash_screen.dart` - Animated splash
- `lib/features/home/home_screen.dart` - Welcome interface
- `lib/features/conversation/conversation_screen.dart` - Main conversation UI

### Animations
- `lib/features/conversation/widgets/speaking_animation.dart` - Speaking visualizations
- `lib/features/conversation/widgets/listening_animation.dart` - Listening animations

## 🎯 Current State

### ✅ Completed
- Complete UI/UX design implementation
- Splash screen with animations
- Home screen with navigation
- Speaking and listening screens with live animations
- State management with Provider
- Modular architecture
- Responsive design
- Clean code structure

### 🔄 Backend Integration Needed
- AI conversation API
- Speech-to-text service
- Text-to-speech service
- User authentication
- Conversation history storage
- Real-time audio processing

## 🛠️ Dependencies

### Core Dependencies
- `flutter` - Flutter framework
- `provider` - State management
- `google_fonts` - Typography

### UI & Animation
- `animated_text_kit` - Text animations
- `lottie` - Animation support (prepared)
- `flutter_svg` - SVG support (prepared)

### Backend Ready (Placeholders)
- `http` - HTTP requests
- `dio` - Advanced HTTP client
- `audioplayers` - Audio playback
- `permission_handler` - Device permissions
- `shared_preferences` - Local storage

## 📋 Future Enhancements

### Immediate (Backend Integration)
1. Connect to AI conversation API
2. Implement speech-to-text functionality
3. Add text-to-speech capability
4. Real-time audio processing

### Extended Features
1. User profiles and authentication
2. Conversation history and analytics
3. Learning progress tracking
4. Multiple conversation topics
5. Offline mode support
6. Multi-language support

## 🎨 Assets

The `assets/` folder is prepared for:
- App icons and logos
- Lottie animations
- Custom illustrations
- Sound effects

Currently using Material Design icons as placeholders.

## 🔍 Code Quality

- Flutter analysis passing (only deprecation warnings)
- Consistent coding standards
- Comprehensive documentation
- Modular and testable architecture
- Type-safe code throughout

## 📱 Platform Support

- ✅ **Web** - Fully functional
- ✅ **iOS** - Ready (requires macOS for testing)
- ✅ **Android** - Ready
- ⚠️ **Desktop** - Requires platform-specific audio dependencies
- ✅ **Responsive** - Adapts to all screen sizes

---

*This project provides a complete, production-ready UI/UX foundation for ConversaAI. The modular architecture ensures easy backend integration and future scalability.*

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
