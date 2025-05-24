# Rivo - Marketplace App

A modern marketplace application built with Flutter, following clean architecture principles.

## Current Implementation Status

### ✅ Implemented UI Components
- **Splash Screen**: Initial loading screen with app branding
- **Authentication Screens**:
  - Login screen UI (no backend integration yet)
  - Form validation placeholders
- **Product Feed**:
  - Basic home screen layout with bottom navigation
  - Placeholder for product listings
- **Product Detail Screen**:
  - Basic layout for product display
  - Image gallery placeholder
  - Seller information section

### ⏳ Pending Implementation
- **Authentication**:
  - Backend integration
  - Session management
  - User registration flow
- **Product Feed**:
  - Real data integration
  - Search and filtering
  - Pagination
- **Wishlist**:
  - Add/remove items
  - Persistence
- **Product Upload**:
  - Image upload
  - Form submission
- **User Profile**:
  - User data display
  - Settings
  - Order history

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Architecture**: Clean Architecture with Feature-First structure
- **Form Handling**: Formz
- **Networking**: Dio
- **Local Storage**: Shared Preferences

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── router/         # Navigation configuration
│   ├── services/       # External services (API, storage, etc.)
│   ├── theme/          # App theming
│   └── utils/          # Helper functions and utilities
│
├── features/          # Feature modules
│   ├── auth/           # Authentication feature
│   │   ├── data/       # Data layer (repositories, data sources)
│   │   ├── domain/     # Business logic (entities, use cases)
│   │   └── presentation/ # UI layer (screens, widgets, state)
│   │
│   ├── product_feed/   # Product listing feature
│   ├── wishlist/       # Wishlist feature
│   ├── product_upload/ # Product upload feature
│   └── profile/        # User profile feature
│
└── main.dart          # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for running on emulator/device)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/rivo.git
   cd rivo
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Running Tests

To run unit tests:
```bash
flutter test
```

## Code Generation

This project uses code generation for Riverpod providers. After modifying any provider annotations, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
