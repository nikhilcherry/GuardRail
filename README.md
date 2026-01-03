# Guardrail - Residential Security Access Management App

A comprehensive Flutter-based mobile application for managing residential security access, visitor verification, and gate control. Developed by **ARVYO**. Built with Flutter for Android (future deployment planned for Google Play Store).

> **Project Status**: Under Development / Pre-release.

## 🎯 Features

### For Guards
- **Visitor Registration**: Register new visitors arriving at the gate
- **Entry Management**: Approve or reject visitor requests
- **Patrol Checkpoints**: Track and log patrol rounds
- **Live Activity Feed**: Real-time view of all gate activities
- **Visitor History**: Access to recent and historical entries

### For Residents
- **Visitor Notifications**: Receive alerts for pending visitor approvals
- **Quick Approval/Rejection**: One-tap approval process for visitors
- **Pre-Approval System**: Generate access codes for future visitors
- **Visitor Management**: Track all past and current visitors
- **Settings & Preferences**: Personalize app behavior and notifications

### For Admins
- **Dashboard Overview**: KPI metrics and system health status
- **Activity Monitoring**: Live feed of all system activities
- **User Management**: Manage guards, residents, and system users
- **Configuration**: Control system features and security parameters
- **Activity Logs**: Comprehensive audit trails and system logs

## 🏗️ Architecture

### Project Structure
```
guardrail_flutter/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── theme/
│   │   └── app_theme.dart       # Theme configuration & styles
│   ├── providers/
│   │   ├── auth_provider.dart   # Authentication state management
│   │   ├── guard_provider.dart  # Guard-specific state
│   │   └── resident_provider.dart # Resident-specific state
│   └── screens/
│       ├── welcome_screen.dart   # Initial landing screen (Login/Sign Up)
│       ├── auth/
│       │   ├── login_screen.dart        # Email/Password login
│       │   ├── sign_up_screen.dart      # Registration screen
│       │   ├── forgot_password_screen.dart # Password recovery
│       │   └── id_verification_screen.dart # Guard ID check
│       ├── guard/
│       │   └── guard_home_screen.dart   # Guard dashboard
│       ├── resident/
│       │   └── resident_home_screen.dart # Resident home
│       └── admin/
│           └── admin_dashboard_screen.dart # Admin panel
├── pubspec.yaml                  # Dependencies
└── README.md
```

### State Management
- **Provider Pattern**: Used for efficient state management across the app
- **AuthProvider**: Manages authentication state and user session
- **GuardProvider**: Handles guard-specific data (visitor entries, patrols)
- **ResidentProvider**: Manages resident notifications and visitor history

### Design System
- **Color Palette**: Dark theme optimized for security applications
  - Primary: #F5C400 (Guardrail Yellow)
  - Background: #0F0F0F (Jet Black)
  - Surface: #141414 (Dark Graphite)
  - Success: #2ECC71 (Bright Green)
  - Error: #E74C3C (Danger Red)

- **Typography**: Inter font family (400-700 weights)
- **Components**: Custom built with Material 3 design principles
- **Dark Theme**: Full-featured dark mode optimized for OLED displays

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extension
- Android NDK (for Android builds)

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd guardrail_flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Android**
```bash
# Update compileSdkVersion in android/app/build.gradle to 34+
# Ensure minSdkVersion is at least 21
```

4. **Run the app**
```bash
# Development
flutter run

# Release
flutter run --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 📱 Screen Flow

### Authentication Flow
1. **Welcome Screen**
   - Options to Login or Sign Up
2. **Sign Up Screen**
   - Enter Name, Email, Phone, Password
   - Select Role (Resident, Guard, Admin)
3. **Login Screen**
   - Email + Password authentication
4. **ID Verification Screen**
   - For Guards: ID check and approval status
5. **Dashboard**
   - Role-specific home screens upon successful login/verification

### Guard Flow
- Home Dashboard with recent entries
- Register New Visitor modal
- Approve/Reject visitor requests
- Patrol checkpoint tracking
- Entry history view

### Resident Flow
- Home screen with pending approvals
- Visitor card with approve/reject buttons
- Recent visitor history
- Visitor management tab
- Settings and preferences

### Admin Flow
- Dashboard with KPI stats
- Live activity feed
- Flat/Family management
- Guard management
- Visitor logs
- System settings
- Activity audit logs

## 🎨 Customization

### Theme
Edit `lib/theme/app_theme.dart` to customize:
- Colors and gradients
- Typography scales
- Component styles
- Border radius values

### API Integration
Replace mock data in providers with actual API calls:
```dart
// Example in auth_provider.dart
Future<void> loginWithEmail({...}) async {
  // Replace with actual API call
  final response = await http.post(
    Uri.parse('https://api.example.com/login'),
    body: {...}
  );
  // Handle response
}
```

## 📦 Key Dependencies

- **provider**: State management (^6.0.0)
- **google_fonts**: Typography (^6.1.0)
- **pin_code_fields**: OTP input widget (^7.4.0)
- **intl**: Internationalization (^0.19.0)
- **shared_preferences**: Local storage (^2.2.0)
- **http**: Network requests (^1.1.0)
- **flutter_animate**: Animations (^4.2.0)

## 🔒 Security Features

- Secure authentication flow
- Password hashing (implement in production)
- JWT token management (to be implemented)
- Role-based access control
- Activity audit logging
- Secure local storage with shared_preferences

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build test APK
flutter build apk --debug
```

## 📈 Performance Optimization

- Lazy loading of screens
- Efficient list rendering with `ListView.separated`
- Provider pattern for minimal rebuilds
- Material 3 animations for smooth UX
- Optimized images and assets

## 🌍 Internationalization

Add language support:
1. Create `lib/l10n/` directory
2. Add language files (e.g., `en.json`, `es.json`)
3. Use `intl` package for translations

## 🚀 Deployment

### Android Release
Future deployment planned for Google Play Store.

```bash
# Create signing key (first time only)
keytool -genkey -v -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias

# Configure signing in android/app/build.gradle
# Build release APK
flutter build apk --release

# Or build App Bundle for Play Store
flutter build appbundle --release
```

## 📝 API Endpoints (To be implemented)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/auth/login` | POST | Phone/Email login |
| `/auth/verify-otp` | POST | Verify OTP |
| `/visitors/register` | POST | Register new visitor |
| `/visitors/approve` | POST | Approve visitor |
| `/visitors/reject` | POST | Reject visitor |
| `/patrol/checkin` | POST | Record patrol check-in |
| `/activity/log` | GET | Get activity history |

## 🤝 Contributing

1. Create a feature branch (`git checkout -b feature/AmazingFeature`)
2. Commit your changes (`git commit -m 'Add AmazingFeature'`)
3. Push to the branch (`git push origin feature/AmazingFeature`)
4. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 👥 Support

For support, please contact via email below or open an issue in the repository.

## 🎓 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Pattern](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io)
- [Dart Language](https://dart.dev/guides)

## 📞 Contact

- **Company**: ARVYO
- **Email**: nikhil.ammisetty@gmail.com (GitHub Integration)
- **Project Status**: Under Development (Android)

---

**Version**: 1.0.0
**Status**: Pre-release
