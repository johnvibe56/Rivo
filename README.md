# RIVO - Vintage Marketplace App

A modern vertical-scroll marketplace app built with Flutter and Supabase. RIVO enables users to discover, wishlist, and purchase vintage and secondhand items with smooth navigation, real-time updates, and clean architecture.

---

## 🚀 Project Status (June 2024)

### ✅ Core Features

* **Authentication** with email/password
* **Infinite Scroll Product Feed** with like/wishlist support
* **Product Upload** with Supabase Storage
* **Wishlist System** with real-time syncing
* **User Profiles** with upload history
* **Product Detail View** with image gallery
* **Cart & Checkout** system
* **Order Management** for buyers and sellers
* **Search & Filters** for product discovery
* **Responsive Design** for all screen sizes

### 🚧 In Development

* Real-time Chat between buyers and sellers
* Advanced seller analytics dashboard
* Push notifications for order updates
* Enhanced search with AI recommendations

---

## 🔧 Tech Stack

| Layer               | Technology                           |
| ------------------- | ------------------------------------ |
| **Frontend**        | Flutter 3.19, Material 3            |
| **State Management**| Riverpod 2.4                        |
| **Navigation**      | Go Router 10.1                      |
| **Backend**         | Supabase (Auth, PostgreSQL, Storage) |
| **Database**        | PostgreSQL with Row-Level Security   |
| **Networking**      | Dio 5.4                             |
| **Forms**           | Formz 0.4.1                         |
| **Local Storage**   | Shared Preferences 2.2.2            |
| **Environment**     | Flutter DotEnv 5.1.0                |
| **Animations**      | Custom Scroll & Page Transitions     |
| **Image Loading**   | Cached Network Image 3.3.1          |
| **Logging**         | Logger 2.0.2                        |

---

## 📱 Main Features

### 🧑‍💻 Authentication

* ✅ Secure login & registration (email/password)
* 🔐 Session persistence
* ✅ Form validation & error feedback
* ⚙️ Optional: email confirmation required (can be disabled in dev)

### 🛍️ Product Feed

* 🎯 Infinite vertical scroll (PageView style)
* 💖 Wishlist / Like functionality
* ⚡ Optimistic UI updates
* 🔄 Real-time loading and error states
* 🖼️ Product cards with image, title, price

### ❤️ Wishlist

* 🔄 Toggle save/remove products
* 📦 View saved items in a dedicated screen
* 🔒 Row-Level Security (RLS) enforcement per user
* 📶 Works offline with fallback behavior
* 📊 Products fetched via JOIN with wishlist table for scoped access

### 📦 Upload Product

* 📤 Image upload via Supabase Storage
* ✏️ Add title, description, and price
* ✅ Form validation and error states
* 🔒 Data scoped to current user
* 👤 Includes `owner_id` from Supabase Auth

### 👤 User Profile Management

* 🧾 View and edit user profile information
* 🖼️ Upload and update profile pictures
* 🔄 Automatic profile creation for new users
* 🔒 Secure profile updates with Row-Level Security (RLS)
* 🧭 Navigation to edit profile screen
* 📧 Show user email from auth
* 🧾 See user's uploaded items
* 🔁 Pull-to-refresh supported
* 🗑️ Product deletion with confirmation

### 🔄 Automatic Profile Creation

* ✨ New users automatically get a default profile
* 🔄 Handles username conflicts by appending numbers
* 🔒 Secure RPC function for profile creation
* 📊 Default username format: `user_<user-id-prefix>`
* ⚡ Optimistic UI updates during profile operations

### 🎬 Scroll Animations

* 🎯 Smooth scroll-based animations for product cards
* 🚀 Optimized performance with efficient widget rebuilding
* 🔄 Customizable animation parameters (fade, slide, scale, rotate)
* 🎨 Configurable animation curves and durations
* 📱 Responsive animations that adapt to different screen sizes

### 🧩 UI/UX & Design

* ☀️ Light theme optimized for better performance
* 📱 Responsive layout (small and large screens)
* 🚦 Loading indicators & error messages
* 🧭 Bottom navigation between Feed, Wishlist, Profile

---

## 🗃️ Project Structure

```txt
lib/
├── core/                # App-wide utilities
│   ├── animations/       # Custom scroll and page animations
│   │   ├── app_animations.dart
│   │   ├── fade_animation.dart
│   │   ├── page_transitions.dart
│   │   └── scroll_animations.dart
│   ├── theme/           # App theming
│   └── utils/           # Utility functions
├── features/
│   ├── auth/            # Sign-in, sign-up
│   ├── product_feed/    # Marketplace product browsing
│   ├── wishlist/        # Wishlist logic & UI
│   ├── product_upload/  # Upload form and storage logic
│   └── profile/         # User profile view
└── main.dart            # Entry point
```

---

## 🧪 Testing

```bash
flutter test  # Run all tests
flutter pub run build_runner build --delete-conflicting-outputs  # Generate provider code
```

---

## 🛠 Setup Guide

### Prerequisites

- Flutter SDK (>= 3.16.0)
- Dart SDK (>= 3.2.0)
- Node.js (>= 16.0.0)
- Supabase Project (Auth + Database + Storage)
- iOS: Xcode 14.0+ with CocoaPods
- Android: Android Studio (latest) or Android SDK 33+

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/rivo.git
   cd rivo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Update .env with your Supabase credentials
   ```

4. **Run the app**
   ```bash
   # For iOS
   cd ios && pod install && cd ..
   flutter run -d ios

   # For Android
   flutter run -d android
   ```

### Supabase Setup

1. Create a new project at [Supabase](https://supabase.com/)
2. Enable Email/Password authentication
3. Set up the database schema by running the SQL from `supabase/migrations/`
4. Configure Storage buckets and Row-Level Security (RLS) policies
5. Update the `.env` file with your Supabase URL and anon key

---

## 📱 Screenshots

<div align="center">
  <img src="screenshots/feed.png" width="200" alt="Product Feed">
  <img src="screenshots/product_detail.png" width="200" alt="Product Detail">
  <img src="screenshots/profile.png" width="200" alt="User Profile">
  <img src="screenshots/cart.png" width="200" alt="Shopping Cart">
</div>

*Screenshots from the latest version of the app*

---

## 🔐 Production Auth Requirements

Before going live, be sure to:

* ✅ Enable **email confirmation** under Supabase → Auth → Settings → Email Auth
* ✅ Set up email templates and branding if needed
* ✅ Enable **rate limiting** and abuse protection
* ✅ Add reCAPTCHA (optional but recommended for sign-ups)

For development:

* You can disable email confirmation to test accounts more quickly

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Report bugs** - [Open an issue](https://github.com/yourusername/rivo/issues) with detailed steps to reproduce
2. **Suggest features** - Share your ideas for new features or improvements
3. **Submit PRs** - Follow our contribution guidelines below

### Development Workflow

1. Fork the repository
2. Create a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Make your changes
4. Run tests and ensure they pass:
   ```bash
   flutter test
   flutter analyze
   ```
5. Commit your changes with a descriptive message:
   ```bash
   git commit -m "feat: add amazing feature"
   ```
6. Push to your fork and open a Pull Request

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Write tests for new features

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙌 Acknowledgments

* Flutter, Supabase, Riverpod, GoRouter
* Everyone contributing to open-source tooling
