# Rivo - Marketplace App

A modern marketplace application built with Flutter and Supabase, following clean architecture principles.

## ✨ Recent Updates

### Wishlist Feature (May 2024)
- Added wishlist functionality to save favorite products
- Implemented wishlist screen with product listings
- Added loading states and error handling
- Integrated with existing authentication system
- Optimized for performance with proper state management

### User Profile Enhancements (May 2024)
- Implemented user product listing with pull-to-refresh
- Added loading states and error handling
- Improved data fetching with proper caching
- Enhanced logging and debugging capabilities
- Optimized performance for user product listings

## 🚀 Features

### Authentication
- ✅ Email/Password Sign In
- ✅ User Registration
- ✅ Form Validation
- ✅ Secure Credential Storage
- ✅ Session Management

### Feed & Product Browsing
- 🎯 Infinite Scrolling Feed
- 🔄 Pull-to-Refresh
- 🎨 Rich Product Cards
- ❤️ Like/Favorite Products with Wishlist integration
- 💬 Product Details & Interactions
- 🛒 Add to Cart Functionality

### Wishlist
- 💖 Save favorite products to your wishlist
- 📱 Access your wishlist from the bottom navigation
- 🔄 Real-time updates when adding/removing items
- 📦 View all wishlisted products in one place
- 🚀 Optimized for performance with local caching

### User Profile
- 👤 View and manage user profile
- 📦 View user's uploaded products
- 🔄 Pull-to-refresh for user products
- 🚀 Optimized loading states
- 🛠 Edit profile information

### User Interface
- 🎨 Dark/Light Theme Support
- 📱 Responsive Design
- 🔄 Smooth Animations
- 🚦 Error Handling
- 🎯 Intuitive Navigation

### ⏳ Upcoming Features
- 🔍 Advanced Search and Filtering
- 📊 Seller Dashboard
- 💬 Real-time Chat
- 📦 Order Tracking
- 🌍 Multi-language Support

## 🛠 Tech Stack

- **Framework**: Flutter 3.x
- **Backend**: Supabase (Auth, Database, Storage)
- **State Management**: Riverpod 2.x
- **Navigation**: Go Router 10.x
- **Architecture**: Clean Architecture with Feature-First structure
- **Form Handling**: Formz
- **Networking**: Dio
- **Local Storage**: Shared Preferences
- **Environment**: Flutter DotEnv
- **UI Components**: Flutter Material Design 3
- **Animation**: Flutter Animation Package
- **Logging**: Custom Logger implementation
- **Error Handling**: Comprehensive error handling with user feedback

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

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.2.0 or higher)
- Android Studio / Xcode (for running on emulator/device)
- Supabase account (for backend services)
- CocoaPods (for iOS development)

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/rivo.git
   cd rivo
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

3. **Set up environment variables**:
   - Copy the example environment file:
     ```bash
     cp .env.example .env
     ```
   - Update the `.env` file with your Supabase credentials

4. **Run the app**:
   ```bash
   # For Android
   flutter run -d <android-device-id>
   
   # For iOS
   flutter run -d <ios-device-id>
   ```

5. **Run tests**:
   ```bash
   flutter test
   ```

### Development Workflow

- Run in development mode:
  ```bash
  flutter run -d <device_id> --debug
  ```

- Run tests:
  ```bash
  flutter test
  ```

- Generate code (if using code generation):
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

## 🧪 Testing

Run the following command to execute all tests:

```bash
flutter test
```

## 📱 Screenshots

| Feed Screen | Product Details | User Profile |
|-------------|----------------|--------------|
| <img src="screenshots/feed_screen.png" width="200"> | <img src="screenshots/product_screen.png" width="200"> | <img src="screenshots/profile_screen.png" width="200"> |

*Screenshots are placeholders - update with actual screenshots from your app*

## 🐛 Bug Reports & Feature Requests

If you find any bugs or have feature requests, please [open an issue](https://github.com/yourusername/rivo/issues) on GitHub. When reporting a bug, please include:
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Device/OS version
- App version

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow the [official Flutter style guide](https://dart.dev/guides/language/effective-dart/style)
- Add comments for complex logic
- Write tests for new features
- Update documentation when adding new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/)
- [Supabase](https://supabase.com/)
- [Riverpod](https://riverpod.dev/)
- [Go Router](https://pub.dev/packages/go_router)

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
