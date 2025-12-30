# 🚀 Guardrail Flutter - Quick Start Guide

## ⚡ 5-Minute Setup

### 1. Clone & Setup
```bash
# Clone the project
git clone <repo-url>
cd guardrail_flutter

# Install dependencies
flutter pub get

# Check environment
flutter doctor
```

### 2. Run the App
```bash
# Start development server
flutter run

# On specific device
flutter run -d <device-id>

# Release build
flutter build apk --release
```

### 3. Hot Reload
```
Save file → Changes appear instantly
Press 'R' → Hot reload
Press 'r' → Hot restart (full reload)
Press 'q' → Quit app
```

---

## 📱 Test Login Credentials

> **Note:** Demo credentials are provided for local development only. Do not use in production.

### Guard Account
- **Phone**: (Demo only - see env)
- **OTP**: (Demo only - see env)
- **Role**: Guard

### Resident Account
- **Phone**: (Demo only - see env)
- **OTP**: (Demo only - see env)
- **Role**: Resident

### Admin Account
- **Email**: (Demo only - see env)
- **Password**: (Demo only - see env)
- **Role**: Admin

---

## 🎯 Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point & routing |
| `lib/theme/app_theme.dart` | Colors, styles, typography |
| `lib/providers/*_provider.dart` | State management |
| `lib/screens/*/` | UI screens |
| `pubspec.yaml` | Dependencies & config |

---

## 🔧 Common Commands

```bash
# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Build APK
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release

# Clean project
flutter clean

# Update packages
flutter pub upgrade
```

---

## 🐛 Quick Debugging

```bash
# Print to console
print('Debug: $value');

# Run in verbose mode
flutter run -v

# Check device
flutter devices

# View logs
flutter logs
```

---

## 📁 Add New Screen

### Step 1: Create Screen File
```dart
// lib/screens/new_feature/new_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
        title: Text('Title', style: AppTheme.headlineMedium),
      ),
      body: Center(
        child: Text('Content', style: AppTheme.bodyLarge),
      ),
    );
  }
}
```

### Step 2: Add Route (in main.dart)
```dart
routes: {
  '/new_screen': (_) => const NewScreen(),
}
```

### Step 3: Navigate
```dart
Navigator.pushNamed(context, '/new_screen');
```

---

## 🎨 Use Theme Colors

```dart
// Primary yellow
AppTheme.primary  // #F5C400

// Dark backgrounds
AppTheme.backgroundDark  // #0F0F0F
AppTheme.surfaceDark     // #141414

// Status colors
AppTheme.successGreen   // #2ECC71
AppTheme.errorRed       // #E74C3C
AppTheme.pending        // #FFC107

// Text colors
AppTheme.textPrimary      // White
AppTheme.textSecondary    // Light gray
AppTheme.textTertiary     // Medium gray
```

---

## 📦 Add Dependencies

```bash
# Search for package
flutter pub search package_name

# Add to pubspec.yaml
dependencies:
  package_name: ^1.0.0

# Get it
flutter pub get
```

---

## 🧪 Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit_test.dart

# Watch mode
flutter test --watch

# Coverage
flutter test --coverage
```

---

## 🔗 State Management

### Use Provider Pattern

```dart
// Create provider
class MyProvider extends ChangeNotifier {
  String _data = '';
  
  String get data => _data;
  
  void updateData(String value) {
    _data = value;
    notifyListeners();
  }
}

// Register (main.dart)
providers: [
  ChangeNotifierProvider(create: (_) => MyProvider()),
]

// Use in widget
Consumer<MyProvider>(
  builder: (context, provider, _) {
    return Text(provider.data);
  },
)

// Update data
context.read<MyProvider>().updateData('new value');
```

---

## 🚀 Optimization Tips

1. **Use const widgets**
   ```dart
   const SizedBox(height: 16)
   ```

2. **Use ListView.builder for lists**
   ```dart
   ListView.builder(itemBuilder: ...)
   ```

3. **Avoid rebuilds**
   ```dart
   Consumer<Provider>(builder: ...)
   ```

4. **Cache images**
   ```dart
   Image.network('url', cacheWidth: 300)
   ```

---

## 📚 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Provider Docs](https://pub.dev/packages/provider)
- [Material Design](https://m3.material.io)
- [Dart Guide](https://dart.dev/guides)

---

## 🆘 Need Help?

1. **Check logs**: `flutter logs`
2. **Read error messages** carefully
3. **Search** Stack Overflow
4. **Try**: `flutter clean && flutter pub get && flutter run`
5. **Ask**: Create GitHub issue

---

## 📝 Next Steps

- [ ] Read `SETUP_GUIDE.md` for detailed setup
- [ ] Review `lib/theme/app_theme.dart` for styling
- [ ] Explore existing screens for examples
- [ ] Implement API integration in services
- [ ] Add new features and test

---

**Happy Coding! 🎉**

Questions? Check `README.md` or `SETUP_GUIDE.md`
