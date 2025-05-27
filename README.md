# RIVO - Vintage Marketplace App

A modern vertical-scroll marketplace app built with Flutter and Supabase. RIVO enables users to discover, wishlist, and upload vintage and secondhand items, with smooth navigation, real-time updates, and clean architecture.

---

## 🚀 MVP Summary (May 2024 - May 2025)

### 🛠️ Recent Improvements (May 2025)

* 🔍 **Type Safety**
  - Added explicit type parameters throughout the codebase
  - Improved type inference with proper generic types
  - Enhanced null safety with proper null checks

* ⚡ **Performance Optimizations**
  - Added `const` constructors where applicable
  - Optimized widget rebuilds with `const` widgets
  - Improved list handling with proper typing

* 🧹 **Code Quality**
  - Resolved all linter warnings
  - Improved code documentation
  - Standardized code style across the codebase
  - Fixed potential memory leaks in controllers

### ✅ Core Features Completed

### ✅ Core Features Completed

* **Authentication** with email/password
* **Infinite Scroll Product Feed** with like/wishlist support
* **Product Upload** with Supabase Storage
* **Wishlist System** with Supabase-backed syncing and UI integration
* **User Profile** displaying uploaded items
* **Product Detail View** with dynamic routing
* **Bottom Navigation** connecting main app areas

### 🔜 In Progress

* Advanced Search & Filters
* Real-time Chat between buyers and sellers
* Seller Dashboard
* Order & Purchase Flow

---

## 🔧 Tech Stack

| Layer            | Technology                   |
| ---------------- | ---------------------------- |
| UI               | Flutter 3.x, Material 3      |
| State Management | Riverpod 2.x                 |
| Navigation       | Go Router 10.x               |
| Backend          | Supabase (Auth, DB, Storage) |
| Networking       | Dio                          |
| Forms            | Formz                        |
| Local Storage    | Shared Preferences           |
| Environment      | Flutter DotEnv               |
| Animations       | Flutter Animations           |
| Logging          | Custom Logger                |
| Code Quality     | Dart Analysis, Linter        |
| Testing          | Mockito, Flutter Test        |

---

## 🚦 Code Quality & Best Practices

### 🛡️ Type Safety
- Strong type system usage throughout the app
- Proper null safety implementation
- Explicit type annotations for better code readability

### ⚡ Performance
- Efficient widget tree with `const` constructors
- Optimized state management with Riverpod
- Lazy loading and pagination for better performance

### 🧪 Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for critical user flows

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

### 👤 User Profile

* 🧾 See user’s uploaded items
* 🔁 Pull-to-refresh supported
* 🧭 Navigation to Upload screen
* 📧 Show user email from auth
* 🗑️ Product deletion with confirmation

### 🧩 UI/UX & Design

* ☀️🌙 Light/Dark theme support
* 📱 Responsive layout (small and large screens)
* 🚦 Loading indicators & error messages
* 🧭 Bottom navigation between Feed, Wishlist, Profile

---

## 🗃️ Project Structure

```txt
lib/
├── core/                # App-wide utilities (router, theme, services)
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

* Flutter SDK (>= 3.16)
* Dart SDK (>= 3.2)
* Supabase Project (Auth + DB)
* iOS: CocoaPods + Xcode
* Android: Android Studio or CLI tools

### Installation

```bash
git clone https://github.com/yourusername/rivo.git
cd rivo
flutter pub get
cd ios && pod install && cd ..
cp .env.example .env  # Insert your Supabase credentials
flutter run
```

---

## 📷 Screenshots (Coming Soon)

| Feed | Product Detail | Profile | Wishlist |
| ---- | -------------- | ------- | -------- |
| 🖼️  | 🖼️            | 🖼️     | 🖼️      |

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

## 📬 Feedback & Contributions

Found a bug or have an idea?

* [Open an issue](https://github.com/yourusername/rivo/issues)
* Pull Requests are welcome!

### Contribution Flow

```bash
git checkout -b feature/myFeature
flutter test
# Make changes
git commit -m "feat: add my feature"
git push origin feature/myFeature
# Open a PR
```

---

## 📄 License

This project is licensed under the MIT License.

---

## 🙌 Acknowledgments

* Flutter, Supabase, Riverpod, GoRouter
* Everyone contributing to open-source tooling
