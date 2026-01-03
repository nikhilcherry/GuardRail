# Guardrail Flutter App - Complete Setup & Implementation Guide

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Environment Setup](#environment-setup)
3. [Project Structure](#project-structure)
4. [Running the App](#running-the-app)
5. [Feature Implementation](#feature-implementation)
6. [API Integration](#api-integration)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

**Guardrail** is a complete Flutter implementation of a residential security access management system with three distinct user roles:

### Key Components
- **Authentication System**: Email/Password login, Sign Up with Role Selection
- **Role-Based Access**: Guard, Resident, Admin dashboards
- **Real-time Notifications**: Visitor approval requests
- **Activity Tracking**: Comprehensive audit logs
- **Dark Theme UI**: Optimized for mobile viewing

### Technology Stack
```
Frontend: Flutter 3.0+
State Management: Provider 6.0+
Local Storage: Shared Preferences
API: REST API (configurable via .env)
```

---

## 🔧 Environment Setup

### Step 1: Install Flutter

**macOS/Linux:**
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

**Windows:**
1. Download [Flutter SDK](https://flutter.dev/docs/get-started/install/windows)
2. Extract to `C:\src\flutter`
3. Add to PATH: `C:\src\flutter\bin`
4. Run `flutter doctor` in PowerShell

### Step 2: Install Android SDK

```bash
# Using Android Studio
# 1. Open Android Studio
# 2. Tools > SDK Manager
# 3. Install:
#    - Android 12 (API 31) or higher
#    - Android Gradle Plugin 7.0+
#    - SDK Build-tools 33+

# Verify
flutter doctor -v
```

### Step 3: Set up IDE

**VS Code:**
```bash
# Install extensions
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
```

**Android Studio:**
1. Install Dart plugin
2. Install Flutter plugin
3. Restart IDE

### Step 4: Create Project

```bash
# Clone repository
git clone <repo-url>
cd guardrail_flutter

# Get dependencies
flutter pub get
```

---

## 📁 Project Structure

```
guardrail_flutter/
├── android/                          # Android-specific code
│   ├── app/
│   │   ├── build.gradle            # App-level build config
│   │   └── src/main/AndroidManifest.xml
│   └── build.gradle                # Project-level config
│
├── ios/                             # iOS-specific code
│
├── lib/
│   ├── main.dart                   # Entry point
│   │
│   ├── theme/
│   │   └── app_theme.dart          # Theme & colors
│   │
│   ├── models/                      # Data models
│   │   ├── user_model.dart
│   │   ├── visitor_entry.dart
│   │   └── activity_log.dart
│   │
│   ├── providers/                   # State management
│   │   ├── auth_provider.dart
│   │   ├── guard_provider.dart
│   │   └── resident_provider.dart
│   │
│   ├── services/                    # API & business logic
│   │   ├── auth_service.dart
│   │   └── logging_service.dart
│   │
│   ├── screens/                     # UI screens
│   │   ├── welcome_screen.dart      # Initial landing
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── sign_up_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── id_verification_screen.dart
│   │   ├── guard/
│   │   │   ├── guard_home_screen.dart
│   │   │   └── patrol_logs_screen.dart
│   │   ├── resident/
│   │   │   ├── resident_home_screen.dart
│   │   │   └── resident_settings_screen.dart
│   │   └── admin/
│   │       ├── admin_dashboard_screen.dart
│   │       ├── admin_flats_screen.dart
│   │       └── admin_guards_screen.dart
│   │
│   ├── widgets/                     # Reusable components
│   │   ├── custom_app_bar.dart
│   │   ├── visitor_card.dart
│   │   └── activity_card.dart
│   │
│   └── utils/                       # Utilities
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/                            # Unit & widget tests
│
├── pubspec.yaml                     # Dependencies
├── README.md                        # Documentation
├── .env.example                     # Environment config example
└── .gitignore
```

---

## 🚀 Running the App

### Development Mode
```bash
# Run on emulator
flutter run

# Run on physical device
flutter devices                    # List connected devices
flutter run -d <device-id>        # Run on specific device

# Enable hot reload (automatic)
# Edit code and save - changes appear instantly

# Hot restart (manual)
# Press 'R' in terminal to restart
```

### Debug Mode
```bash
# Run with debug output
flutter run -v

# Enable dart debug prints
# In your code: print('Debug message');
```

### Release Mode
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/apk/release/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

---

## 🔨 Feature Implementation

### 1. Adding New Screens

```dart
// Create new screen
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NewScreen extends StatefulWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text('New Screen', style: AppTheme.headlineMedium),
      ),
      body: Center(
        child: Text('Content here', style: AppTheme.bodyLarge),
      ),
    );
  }
}
```

### 2. Adding Navigation Routes

```dart
// In lib/router/app_router.dart, add to router definition
GoRoute(
  path: '/new-screen',
  builder: (context, state) => const NewScreen(),
),

// Navigate
context.push('/new-screen');
```

### 3. Adding State Management

```dart
// Create new provider
import 'package:flutter/foundation.dart';

class NewProvider extends ChangeNotifier {
  String _data = '';
  
  String get data => _data;
  
  void updateData(String newData) {
    _data = newData;
    notifyListeners();
  }
}

// Use in main.dart
providers: [
  ChangeNotifierProvider(create: (_) => NewProvider()),
]

// Use in widget
Consumer<NewProvider>(
  builder: (context, provider, _) {
    return Text(provider.data);
  },
)
```

### 4. Validation

```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone is required';
    if (value.length < 10) return 'Phone must be at least 10 digits';
    return null;
  }
}
```

---

## 🔗 API Integration

### Setting up API Service

```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  
  // Get token from secure storage
  static Future<String?> getToken() async {
    // Implement token retrieval from secure storage
    return null;
  }
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Login endpoint
  static Future<Map> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
```

### Integrating with Providers

```dart
// Update auth_provider.dart
Future<void> loginWithEmail({
  required String email,
  required String password,
}) async {
  try {
    final response = await ApiService.login(email, password);
    
    // Save token logic...
    
    _isLoggedIn = true;
    notifyListeners();
  } catch (e) {
    rethrow;
  }
}
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Gradle Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### 2. Android SDK Issues
```bash
# Accept all licenses
flutter doctor --android-licenses

# Check SDK path
flutter doctor -v
```

#### 3. Permission Issues (Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

### Debug Output

```bash
# Verbose mode
flutter run -v 2>&1 | tee debug.log

# Print statements
print('Debug: $variable');

# Use debugPrint for better formatting
import 'package:flutter/foundation.dart';
debugPrint('Message: $value');
```

---

## 📚 Additional Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Dart Docs**: https://dart.dev/guides
- **Provider Package**: https://pub.dev/packages/provider
- **Material Design**: https://m3.material.io

---

**Status**: Pre-release ✅
