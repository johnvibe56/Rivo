# Rivo - Marketplace App

A modern marketplace application built with Flutter and Supabase, following clean architecture principles.

## 🚀 Features

### Authentication
- ✅ Email/Password Sign In
- ✅ User Registration
- ✅ Form Validation
- ✅ Secure Credential Storage
- ✅ Session Management

### User Interface
- 🎨 Dark/Light Theme Support
- 📱 Responsive Design
- 🔄 Loading States
- 🚦 Error Handling
- 🎯 Focus on UX Best Practices

### ⏳ Upcoming Features
- 🛍️ Product Listings
- 🔍 Search and Filtering
- ❤️ Wishlist
- 🛒 Shopping Cart
- 📦 Order Management
- 📊 Seller Dashboard

## 🛠 Tech Stack

- **Framework**: Flutter
- **Backend**: Supabase (Auth, Database, Storage)
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Architecture**: Clean Architecture with Feature-First structure
- **Form Handling**: Formz
- **Networking**: Dio
- **Local Storage**: Shared Preferences
- **Environment**: Flutter DotEnv
- **UI Components**: Flutter Material Design 3

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

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for running on emulator/device)
- Supabase account (for backend services)

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/rivo.git
   cd rivo
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**:
   - Create a `.env` file in the root directory
   - Add your Supabase credentials:
     ```
     SUPABASE_URL=your_supabase_project_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

4. **Run the app**:
   ```bash
   flutter run
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

*Add screenshots of your app here*

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

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
