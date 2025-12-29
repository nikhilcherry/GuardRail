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
- **Authentication System**: Phone OTP & Email/Password login
- **Role-Based Access**: Guard, Resident, Admin dashboards
- **Real-time Notifications**: Visitor approval requests
- **Activity Tracking**: Comprehensive audit logs
- **Dark Theme UI**: Optimized for mobile viewing

### Technology Stack
```
Frontend: Flutter 3.0+
State Management: Provider 6.0+
Local Storage: Shared Preferences
Database: Firebase (optional)
API: REST API (configurable)
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
# Clone repository or create new
cd /path/to/projects
flutter create guardrail_flutter

# Or clone from git
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
├── ios/                             # iOS-specific code (optional)
│
├── lib/
│   ├── main.dart                   # Entry point
│   │
│   ├── theme/
│   │   └── app_theme.dart          # Theme & colors
│   │
│   ├── models/                      # Data models (to add)
│   │   ├── user.dart
│   │   ├── visitor.dart
│   │   └── activity.dart
│   │
│   ├── providers/                   # State management
│   │   ├── auth_provider.dart
│   │   ├── guard_provider.dart
│   │   └── resident_provider.dart
│   │
│   ├── services/                    # API & business logic (to add)
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── visitor_service.dart
│   │
│   ├── screens/                     # UI screens
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── role_selection_screen.dart
│   │   ├── guard/
│   │   │   ├── guard_home_screen.dart
│   │   │   ├── visitor_details_screen.dart
│   │   │   └── patrol_logs_screen.dart
│   │   ├── resident/
│   │   │   ├── resident_home_screen.dart
│   │   │   ├── visitor_management_screen.dart
│   │   │   └── settings_screen.dart
│   │   └── admin/
│   │       ├── admin_dashboard_screen.dart
│   │       ├── activity_logs_screen.dart
│   │       ├── flats_management_screen.dart
│   │       ├── guards_management_screen.dart
│   │       └── admin_settings_screen.dart
│   │
│   ├── widgets/                     # Reusable components
│   │   ├── custom_app_bar.dart
│   │   ├── visitor_card.dart
│   │   └── activity_card.dart
│   │
│   └── utils/                       # Utilities
│       ├── constants.dart
│       ├── validators.dart
│       └── extensions.dart
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

### Web (Optional)
```bash
# Enable web support
flutter config --enable-web

# Run web version
flutter run -d web-javascript
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
// In main.dart, add to MaterialApp
routes: {
  '/login': (_) => const LoginScreen(),
  '/role_selection': (_) => const RoleSelectionScreen(),
  '/guard_home': (_) => const GuardHomeScreen(),
  '/resident_home': (_) => const ResidentHomeScreen(),
  '/admin_home': (_) => const AdminDashboardScreen(),
},

// Navigate
Navigator.pushNamed(context, '/guard_home');

// Or with arguments
Navigator.pushNamed(
  context,
  '/visitor_details',
  arguments: visitor,
);
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

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'OTP must be 6 digits';
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

class ApiService {
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/v1';
  
  // Get token from secure storage
  static Future<String?> getToken() async {
    // Implement token retrieval from secure storage
    return null;
  }
  
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Login endpoint
  static Future<Map> login(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/auth/login'),
        headers: await getHeaders(),
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
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
  
  // Register visitor endpoint
  static Future<Map> registerVisitor({
    required String name,
    required String flatNumber,
    required String purpose,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/visitors/register'),
        headers: await getHeaders(),
        body: jsonEncode({
          'name': name,
          'flat_number': flatNumber,
          'purpose': purpose,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register visitor');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
```

### Integrating with Providers

```dart
// Update auth_provider.dart
Future<void> loginWithPhoneAndOTP({
  required String phone,
  required String otp,
}) async {
  try {
    final response = await ApiService.login(phone, otp);
    
    // Save token
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setString('token', response['token']));
    
    _isLoggedIn = true;
    _userPhone = phone;
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
flutter pub upgrade
flutter run
```

#### 2. Android SDK Issues
```bash
# Accept all licenses
flutter doctor --android-licenses

# Check SDK path
flutter doctor -v

# Update SDK in pubspec
sdk: ">=3.0.0 <4.0.0"
```

#### 3. Dependency Conflicts
```bash
# Get latest versions
flutter pub get --upgrade

# Check for conflicts
flutter pub upgrade
```

#### 4. Hot Reload Not Working
```bash
# Restart app fully
flutter clean
flutter run

# Or kill and restart
# Press 'q' to quit, then flutter run
```

#### 5. Permission Issues (Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
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

## 📊 Performance Tips

1. **Use const constructors**
   ```dart
   const SizedBox(height: 16)  // ✅ Good
   SizedBox(height: 16)        // ❌ Avoid
   ```

2. **Lazy load lists**
   ```dart
   ListView.builder(  // ✅ Efficient
     itemCount: items.length,
     itemBuilder: (_, index) => ...,
   )
   ```

3. **Avoid rebuilds**
   ```dart
   Consumer<Provider>(  // Only rebuilds when Provider changes
     builder: (_, provider, __) => ...,
   )
   ```

4. **Profile your app**
   ```bash
   flutter run --profile
   # Use DevTools: http://localhost:9100
   ```

---

## 📚 Additional Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Dart Docs**: https://dart.dev/guides
- **Provider Package**: https://pub.dev/packages/provider
- **Material Design**: https://m3.material.io
- **Stack Overflow**: [Tag: flutter]

---

## ✅ Deployment Checklist

- [ ] Update version in pubspec.yaml
- [ ] Test on multiple devices/APIs
- [ ] Run `flutter analyze` for issues
- [ ] Update README with latest features
- [ ] Create signed APK/AAB
- [ ] Test release build
- [ ] Set up CI/CD pipeline
- [ ] Configure play store listing
- [ ] Submit for review

---

**Last Updated**: 2024  
**Status**: Ready for Development ✅
