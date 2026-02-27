# 🛒 Daraz-Style Product Listing — Flutter Hiring Task 2026

A Flutter application that replicates a Daraz-style product listing experience, built as part of the ZaviSoft Flutter Developer hiring task.

> ⚠️ **This is not a UI-focused project.**
> The primary goal is demonstrating correct scroll architecture and gesture coordination using a single vertical scrollable.

---

## ✨ Features

### 🛍 Product Listing
Fetches and displays products from the [FakeStore API](https://fakestoreapi.com/) in a responsive 2-column `SliverGrid`.

### 📂 Category Tabs
Products are grouped by category with a sticky Sliver-based tab bar.
Categories can be switched by:
- Tapping on a tab
- Swiping horizontally on product cards

### 🏷 Collapsible Header
A `SliverAppBar`-based collapsible header containing:
- Banner image
- Personalized greeting with user profile

The tab bar pins to the top once the header collapses.

### 🔄 Pull-to-Refresh
Refreshing works from any category.
The `RefreshIndicator` wraps the root `CustomScrollView`, ensuring no additional scrollables are introduced.

### 🔐 Firebase Authentication
- Email/Password Sign-up & Login
- Google Sign-In
- Auth state–driven navigation

### ♻️ Reusable Widgets
Common components are extracted into reusable widgets:
- Buttons
- Form fields
- Error boxes
- Product cards

---

## 🏗️ Architecture

The project follows **MVVM (Model–View–ViewModel)** with clear separation of concerns.

```
lib/
├── main.dart
├── firebase_options.dart
│
├── models/
│   └── models.dart
│
├── services/
│   └── api_service.dart
│
├── viewmodels/
│   ├── auth_viewmodel.dart
│   ├── home_viewmodel.dart
│   └── gesture_viewmodel.dart
│
└── ui/
    ├── screens/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   └── home_screen.dart
    │
    └── widgets/
        ├── home_app_bar.dart
        ├── category_tab_bar.dart
        ├── product_card.dart
        ├── sliver_tab_bar_delegate.dart
        ├── auth_heading.dart
        ├── app_text_form_field.dart
        ├── auth_error_box.dart
        └── app_buttons.dart
```

---

## 🔧 Scroll & Gesture Architecture *(Core Evaluation Section)*

### The Core Constraint: Exactly One Vertical Scrollable

The entire home screen is driven by a single `CustomScrollView`.

There is:
- ❌ No `NestedScrollView`
- ❌ No `TabBarView`
- ❌ No `PageView`
- ❌ No inner `ListView`

This guarantees:
- One vertical scroll owner
- No nested scroll conflicts
- No scroll jitter
- No scroll position resets
- No duplicate gesture arenas

Because the layout is entirely Sliver-based, switching categories does not recreate or replace the scrollable.
Therefore, the vertical scroll offset remains intact across tab switches.

### Who Owns What

| Concern | Owner |
|---------|-------|
| Vertical scroll | Root `CustomScrollView` (exclusive owner) |
| Pull-to-refresh | `RefreshIndicator` wrapping the root scroll view |
| Horizontal swipe logic | `ScrollGestureViewModel` |
| Tab state | `TabController` (synced with gesture ViewModel) |
| Product data | `HomeViewModel` |
| Authentication | `AuthViewModel` |

> Vertical scroll ownership is **never shared**.

---

### 🖐 Horizontal Swipe Implementation

Since using `PageView` or `TabBarView` would introduce an additional scrollable, horizontal swiping is implemented **manually**.

**How it works:**

1. Each product card is wrapped with a `GestureDetector`
2. It captures `onHorizontalDragStart`, `onHorizontalDragUpdate`, `onHorizontalDragEnd`
3. Drag distance is forwarded to `ScrollGestureViewModel`
4. If a threshold is crossed:
   - The `TabController` index changes
   - An animation is triggered
   - The `SliverGrid` rebuilds with the selected category

**Why gestures are scoped to product cards:**

Horizontal gestures are intentionally attached to product cards instead of the entire viewport to avoid intercepting vertical drag gestures at the root level.

This prevents gesture arena conflicts between vertical scroll and horizontal swipe detection.
Gesture ownership is explicit and predictable.

---

### 📌 Why `TabBarView` Was Avoided

`TabBarView` internally introduces its own scrollable behavior.
Using it would result in:
- Competing vertical scroll contexts
- Complex nested scroll coordination
- Risk of scroll offset resets

To maintain a strict single-scroll architecture, category switching is implemented via `TabController` state changes + `SliverGrid` rebuild.
This keeps vertical scroll ownership centralized and stable.

---

## ⚖️ Trade-offs & Limitations

**1️⃣ Swipe Detection Area**
Swiping is detected only when dragging on product cards, not in empty grid padding.
A viewport-level gesture detector (or custom `RenderSliver` solution) would capture all horizontal drags, but would significantly increase implementation complexity.

**2️⃣ Global Scroll Offset**
The vertical scroll offset is global across categories — scroll position is preserved across tab switches, but per-tab scroll memory is not implemented.
This is an intentional trade-off to preserve architectural simplicity and single scroll ownership.

**3️⃣ Grid Rebuild on Tab Switch**
Switching categories rebuilds the `SliverGrid` instead of keeping multiple slivers alive.
This reduces memory usage but does not support partial in-progress swipe animations across entire grids.

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x or later
- Android Studio / VS Code
- Firebase project configured

### Setup

```bash
git clone https://github.com/NahidAlamRahat/ZaviSoft-Task.git
cd zavisoft_task
flutter pub get
flutter run
```

### Firebase Configuration
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an Android app with package name `com.example.zavisoft_task`
3. Add your SHA-1 fingerprint: `cd android && ./gradlew signingReport`
4. Download `google-services.json` → place it in `android/app/`
5. Enable **Email/Password** and **Google** sign-in under Authentication → Sign-in method

---

## 🔥 Why This Architecture

This implementation prioritizes:
- Deterministic scroll ownership
- Predictable gesture behavior
- Clean separation of concerns
- No fragile hacks, no magic numbers, no global scroll controllers

The goal was not UI polish, but **architectural correctness and gesture coordination clarity**.

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `google_sign_in` | Google login |
| `provider` | State management (MVVM) |
| `http` | FakeStore API client |
| `cached_network_image` | Image caching |

---

## 📝 License

Built as a Flutter hiring task submission for ZaviSoft.
