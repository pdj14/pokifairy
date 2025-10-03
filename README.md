# PokiFairy 🧚✨

**Your Pocket Fairy Companion with On-Device AI Assistant**

PokiFairy is a Flutter application that combines a virtual fairy companion experience with powerful on-device AI chat capabilities. Built with Flutter 3.35+, Riverpod state management, and GGUF/llama.cpp for local AI inference.

## ✨ Features

### 🧚 Fairy Companion
- **Virtual Pet Care**: Feed, play with, and nurture your pocket fairy
- **Growth System**: Watch your fairy grow and evolve based on care
- **Mood Tracking**: Monitor happiness, hunger, and health stats
- **Daily Journal**: Record your fairy's journey and milestones
- **Customization**: Personalize your fairy's appearance and environment

### 🤖 On-Device AI Chat
- **Privacy-First**: All AI processing happens locally on your device
- **Offline Capable**: Chat with AI without internet connection
- **Multiple Models**: Support for various GGUF format models (Gemma, Llama, etc.)
- **Streaming Responses**: Real-time AI response generation
- **Chat History**: Persistent conversation history
- **Model Management**: Easy model selection and debugging tools

### 🌍 Localization
- **Multi-language Support**: Korean (한국어) and English
- **Dynamic Switching**: Change language on the fly
- **Comprehensive Coverage**: All UI elements and error messages localized

### 🎨 Modern UI/UX
- **Material Design 3**: Beautiful, consistent design language
- **Dark Mode**: Full dark theme support
- **Smooth Animations**: Lottie animations and fluid transitions
- **Accessibility**: Semantic labels and screen reader support
- **Responsive Layout**: Adapts to different screen sizes

## 📋 Requirements

- **Flutter**: 3.35 or higher
- **Dart**: 3.9 or higher
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Storage**: ~500MB-2GB for AI models (depending on model size)

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd PokiFairy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up AI models** (Optional but recommended)
   - See [AI Model Setup Guide](docs/AI_MODEL_SETUP.md) for detailed instructions
   - Download a GGUF model and place it in the appropriate directory
   - Supported locations:
     - Android: `/storage/emulated/0/Download/`
     - iOS: App Documents directory

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Commands

```bash
# Run tests
flutter test

# Run integration tests
flutter test integration_test/

# Analyze code
flutter analyze

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## 📁 Project Structure

```
PokiFairy/
├── lib/
│   ├── app/                    # App configuration
│   │   ├── app_router.dart     # GoRouter navigation setup
│   │   └── theme.dart          # Material theme definitions
│   ├── features/               # Feature modules
│   │   ├── home/               # Home screen
│   │   ├── chat/               # AI chat interface
│   │   ├── ai_model/           # Model selection & debug
│   │   ├── care/               # Fairy care screen
│   │   ├── journal/            # Daily journal
│   │   ├── settings/           # App settings
│   │   ├── onboarding/         # First-time user flow
│   │   └── landing/            # Landing page
│   ├── shared/                 # Shared resources
│   │   ├── data/               # Data persistence
│   │   ├── model/              # Data models
│   │   ├── providers/          # Riverpod providers
│   │   ├── services/           # Business logic
│   │   │   └── ai/             # AI service layer
│   │   ├── widgets/            # Reusable widgets
│   │   └── utils/              # Utility functions
│   ├── l10n/                   # Localization files
│   │   ├── app_en.arb          # English translations
│   │   └── app_ko.arb          # Korean translations
│   └── main.dart               # App entry point
├── android/                    # Android native code
│   └── app/src/main/cpp/       # C++ AI inference engine
├── ios/                        # iOS native code
│   └── Runner/NativeBridge/    # Objective-C++ bridge
├── test/                       # Unit & widget tests
├── integration_test/           # Integration tests
└── docs/                       # Documentation
```

For detailed architecture information, see [Architecture Documentation](docs/ARCHITECTURE.md).

## 🔧 Key Technologies

### Frontend
- **Flutter 3.35+**: Cross-platform UI framework
- **Riverpod 3.0**: Reactive state management
- **GoRouter 16.2**: Type-safe navigation
- **Google Fonts**: Typography (Noto Sans KR)
- **Lottie**: Vector animations

### AI Layer
- **GGUF/llama.cpp**: On-device AI inference
- **FFI (Foreign Function Interface)**: Dart ↔ C++ bridge
- **Native Bindings**: Android (JNI) and iOS (Objective-C++)

### Data & Storage
- **shared_preferences**: Settings and preferences
- **File System**: AI model storage and chat history

## 🧪 Testing

The project includes comprehensive test coverage:

- **Unit Tests**: Core business logic and data models
- **Widget Tests**: UI components and user interactions
- **Integration Tests**: End-to-end user workflows

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

See [Test Implementation Summary](TEST_IMPLEMENTATION_SUMMARY.md) for details.

## 📱 Screenshots

<!-- TODO: Add screenshots here -->
```
[Home Screen]  [Fairy Care]  [AI Chat]  [Model Selection]
```

## 🔐 Privacy & Security

- **100% On-Device**: All AI processing happens locally
- **No Data Collection**: No user data sent to external servers
- **Offline First**: Core features work without internet
- **Local Storage**: All data stored securely on device

## 🌟 Roadmap

### Short-term (v1.1 - v1.2)
- [ ] Hive database migration for better performance
- [ ] Voice input/output for AI chat
- [ ] Multi-model comparison feature
- [ ] Enhanced fairy animations
- [ ] Cloud backup (optional, encrypted)

### Long-term (v2.0+)
- [ ] RAG (Retrieval-Augmented Generation) support
- [ ] Custom model fine-tuning
- [ ] Multimodal AI (image, audio)
- [ ] Fairy personality customization
- [ ] Social features (share fairy progress)

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **llama.cpp**: For the excellent on-device inference engine
- **Flutter Team**: For the amazing cross-platform framework
- **Riverpod**: For robust state management
- **Community**: For all the open-source contributions

## 📞 Support

- **Documentation**: Check the [docs/](docs/) folder
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join our community discussions

## 📚 Additional Documentation

- [AI Model Setup Guide](docs/AI_MODEL_SETUP.md)
- [Architecture Overview](docs/ARCHITECTURE.md)
- [Localization Summary](LOCALIZATION_SUMMARY.md)
- [Performance Optimizations](PERFORMANCE_OPTIMIZATIONS.md)
- [State Management Implementation](STATE_MANAGEMENT_IMPLEMENTATION.md)
- [Deeplink Testing](DEEPLINK_TESTING.md)

---

Made with ❤️ using Flutter
