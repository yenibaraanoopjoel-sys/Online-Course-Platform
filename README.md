# 🎓 EduPlatform — Modern Online Course Platform

A full-stack, responsive, production-ready **Online Course Platform** built with **Flutter Web** and **Firebase**.

[![Deployment Status](https://img.shields.io/badge/Deployment-Live%20on%20Firebase-00C853?style=for-the-badge&logo=firebase)](https://onilne-course-platform.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.0-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-v12+-FFCA28?style=for-the-badge&logo=firebase)](https://console.firebase.google.com/project/onilne-course-platform/overview)

---

## 🌐 Live Deployment

* **Production URL:** [https://onilne-course-platform.web.app](https://onilne-course-platform.web.app)
* **Alternative Domain:** [https://onilne-course-platform.firebaseapp.com](https://onilne-course-platform.firebaseapp.com)
* **Firebase Console:** [https://console.firebase.google.com/project/onilne-course-platform/overview](https://console.firebase.google.com/project/onilne-course-platform/overview)

---

## ✨ Features & Capabilities

### 👨‍🎓 Student Experience
* **Course Discovery & Search**: Full search by course titles and categories with dynamic filters (Level: Beginner, Intermediate, Advanced; Pricing: Free / Paid).
* **Course Details & Preview**: Rich course overview with instructor info, curriculum outline, duration, enrollment stats, and description.
* **Instant Course Enrollment**: One-click seamless enrollment with automatic progress tracker creation.
* **Interactive Learning Screen**:
  * Video player integration for course video lectures.
  * Lesson sidebar with checkmarks for completed lessons.
  * Rich lesson reading material, notes, and study guides.
  * Real-time progress updates stored directly in Cloud Firestore.
  * Navigation between previous and next lessons.
* **Personalized Student Dashboard**:
  * "Continue Learning" section with progress indicators and instant resume buttons.
  * Overview statistics: enrolled courses count, completed courses count.
  * Recommended top courses.
* **Student Profile & Account Settings**:
  * Update full name and personal information.
  * Password reset link dispatch.
  * Quick access to enrolled courses and learning statistics.

### 🛡️ Instructor & Admin Portal
* **Role-Based Navigation**: Responsive dashboard layout (adaptive NavigationRail on desktop/tablet, bottom bar on mobile).
* **Platform KPIs & Overview**:
  * Total courses count.
  * Published courses vs draft courses count.
  * Total platform student enrollments.
* **Course Management**:
  * Create, edit, and delete courses.
  * Toggle publish status (Live / Draft).
  * Configure thumbnails, difficulty levels, pricing, and category tags.
* **Curriculum & Lesson Builder**:
  * Add video lessons and markdown educational notes.
  * Sequence lessons with custom order indices.
  * Set lesson durations and toggle visibility.
* **Category Management**:
  * Create, edit, and manage category taxonomies with custom icons and descriptions.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Frontend Framework** | [Flutter](https://flutter.dev) (Channel Stable, Flutter 3.47+) |
| **Language** | Dart 3.13+ |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Navigation & Routing** | [GoRouter](https://pub.dev/packages/go_router) (Declarative routing with auth guards & shells) |
| **Authentication** | Firebase Authentication (Email/Password, Session state management) |
| **Database** | Cloud Firestore (Real-time snapshots, composite indexes, collections) |
| **Storage & Media** | Firebase Storage & Web Video Player |
| **Hosting & CDN** | Firebase Hosting (Global SSL, CDN caching, single-page rewrites) |
| **UI Design System** | Custom modern typography, glassmorphism, responsive grids, curated color palette |

---

## 📁 Project Architecture

```
Online-Course-Platform/
├── lib/
│   ├── core/
│   │   ├── constants/       # AppColors, AppStrings, AppConstants
│   │   ├── theme/           # AppTheme ThemeData & styling
│   │   ├── utils/           # Helpers, Validators, Date formatters
│   │   └── widgets/         # Reusable CourseCards, StatCards, CustomButtons, Loaders
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── course_model.dart
│   │   ├── lesson_model.dart
│   │   ├── category_model.dart
│   │   ├── enrollment_model.dart
│   │   └── progress_model.dart
│   ├── routes/
│   │   └── app_routes.dart  # GoRouter config with auth redirect guards & shells
│   ├── screens/
│   │   ├── auth/            # Login, Registration screens
│   │   ├── splash/          # Splash & auth redirect screen
│   │   ├── student/         # Dashboard, Browse, Details, My Courses, Learning, Profile
│   │   └── admin/           # Admin Dashboard, Course CRUD, Lesson CRUD, Category CRUD
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── course_service.dart
│   │   ├── lesson_service.dart
│   │   ├── category_service.dart
│   │   ├── enrollment_service.dart
│   │   ├── progress_service.dart
│   │   └── storage_service.dart
│   ├── firebase_options.dart # Production Firebase configuration
│   └── main.dart             # App entry point & provider tree
├── web/                      # Web manifest, icons, index.html
├── firestore.rules           # Cloud Firestore Security Rules
├── firebase.json             # Firebase Hosting & deployment configuration
├── .firebaserc               # Firebase project mapping
└── pubspec.yaml              # Dependencies and asset declarations
```

---

## 🔒 Security Rules (Cloud Firestore)

Production security rules enforced in [`firestore.rules`](file:///c:/Users/HP/Desktop/Online-Course-Platform/Online-Course-Platform/firestore.rules):
* **Users**: Each user can only mutate their own profile; admins have management privileges.
* **Courses**: Published courses are publicly readable; only administrators can create, update, publish, or delete courses.
* **Lessons**: Accessible to authenticated users enrolled in the course; editable only by admins.
* **Enrollments & Progress**: Strictly isolated per user (`request.auth.uid == studentId`) preventing cross-student data access.

---

## 🚀 Getting Started & Local Development

### 1. Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.0.0`)
* [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
* Google Chrome or any modern web browser

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/yenibaraanoopjoel-sys/Online-Course-Platform.git
cd Online-Course-Platform

# Install dependencies
flutter pub get
```

### 3. Run Locally
```bash
# Run in Chrome
flutter run -d chrome
```

### 4. Build & Deploy
```bash
# Build production web bundle
flutter build web --release

# Deploy to Firebase Hosting and Firestore
firebase deploy --project onilne-course-platform
```

---

## 👥 Default Roles & Authentication

1. **Student Account**: Register any new account on the register page (`/register`) to start exploring, enrolling in courses, and tracking learning progress.
2. **Admin Account**: Accounts designated with `role: 'admin'` in the `users` Firestore collection automatically receive full access to the `/admin` portal and management tools.

---

## 📄 License
This project is licensed under the MIT License.
