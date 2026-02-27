# 🛒 Daraz-Style Product Listing — Flutter Hiring Task 2026

A Flutter application that replicates a Daraz-style product listing experience, built as part of the ZaviSoft Flutter Developer hiring task.

## ✨ Features

- **Product Listing** — Fetches and displays products from the [FakeStore API](https://fakestoreapi.com/) in a responsive 2-column grid.
- **Category Tabs** — Products are organized by category with a sticky, scrollable tab bar. Switch between categories by tapping a tab or swiping horizontally on the product grid.
- **Collapsible Header** — A banner image and personalized greeting that collapses as you scroll down, with the tab bar pinning at the top.
- **Pull-to-Refresh** — Swipe down from any category to reload all products.
- **Firebase Authentication** — Email/password signup and login with Google Sign-In support.
- **Reusable Widgets** — Common UI components (buttons, form fields, error boxes, product cards) are extracted into a shared widget library.

## 🏗️ Architecture

The project follows **MVVM (Model-View-ViewModel)** with clear separation of concerns:

```
lib/
├── main.dart                     # App entry point, Firebase init, Provider setup
├── firebase_options.dart         # Firebase configuration
│
├── models/
│   └── models.dart               # User and Product data models
│
├── services/
│   └── api_service.dart          # HTTP client for FakeStore API
│
├── viewmodels/
│   ├── auth_viewmodel.dart       # Login, Signup, Google Sign-In, auth state
│   ├── home_viewmodel.dart       # Product fetching, category extraction
│   └── gesture_viewmodel.dart    # Horizontal swipe gesture ownership
│
└── ui/
    ├── screens/
    │   ├── login_screen.dart     # Login page
    │   ├── signup_screen.dart    # Registration page
    │   └── home_screen.dart      # Main product listing screen
    │
    └── widgets/
        ├── home_app_bar.dart           # Collapsible header with user profile
        ├── category_tab_bar.dart       # Sticky category tabs
        ├── product_card.dart           # Product grid item
        ├── sliver_tab_bar_delegate.dart # SliverPersistentHeader delegate
        ├── auth_heading.dart           # Auth screen title/subtitle
        ├── app_text_form_field.dart    # Reusable text input with validation
        ├── auth_error_box.dart         # Styled error message box
        └── app_buttons.dart            # Primary and Google sign-in buttons
```

## 🔧 Scrolling & Gesture Design

### The Core Constraint: One Vertical Scrollable

The entire home screen uses a **single `CustomScrollView`** as its only scrollable widget. There is no `NestedScrollView`, `TabBarView`, or `PageView` anywhere in the widget tree. This avoids the gesture conflicts, jittering, and scroll-jumping issues that come with nesting multiple scrollables.

### How Horizontal Swiping Works

Since we can't use `PageView` (it would introduce a second scrollable), horizontal category swiping is implemented **manually** through a dedicated `ScrollGestureViewModel`:

1. Each product card has a `GestureDetector` that captures `onHorizontalDragStart`, `onHorizontalDragUpdate`, and `onHorizontalDragEnd`.
2. These raw drag signals are forwarded to `ScrollGestureViewModel`, which tracks drag distance and determines whether a swipe threshold was crossed.
3. On successful swipe, it triggers an `AnimationController` to smoothly animate the tab transition.
4. The ViewModel notifies listeners, which causes the `SliverGrid` to rebuild with the new category's products.

### Who Owns What

| Concern | Owner |
|---------|-------|
| Vertical scroll | Root `CustomScrollView` (exclusively) |
| Horizontal swipe | `ScrollGestureViewModel` (gesture state + animation) |
| Tab state | `TabController` synced bidirectionally with `ScrollGestureViewModel` |
| Product data | `HomeViewModel` |
| Auth state | `AuthViewModel` |

### Trade-offs

1. **Swipe detection area** — Swiping only registers on product cards, not in the empty padding between them. A `RenderSliver`-based approach would capture all horizontal drags at the viewport level, but adds significant complexity.
2. **Lazy rendering** — `SliverGrid` builds items lazily as they scroll into view, so whole-grid translation animations during mid-swipe are limited.

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x or later
- Firebase project configured (see below)
- Android Studio or VS Code

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd zavisoft_task

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Configuration

This project uses Firebase for authentication. To set it up:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Add an Android app with package name `com.example.zavisoft_task`.
3. Add your device's SHA-1 fingerprint (get it via `cd android && ./gradlew signingReport`).
4. Download the generated `google-services.json` and place it in `android/app/`.
5. Enable **Email/Password** and **Google** sign-in providers under Authentication → Sign-in method.

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Email/password and Google authentication |
| `google_sign_in` | Google Sign-In flow |
| `provider` | State management (MVVM) |
| `http` | HTTP client for FakeStore API |
| `cached_network_image` | Image caching and loading |

## 📝 License

This project was built as a hiring task submission for ZaviSoft.
