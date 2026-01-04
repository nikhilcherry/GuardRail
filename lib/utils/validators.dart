class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^[6-9]\d{9}$',
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$',
  );

  static final RegExp _alphanumericRegex = RegExp(
    r'^[a-zA-Z0-9]+$',
  );

  static final RegExp _vehicleRegex = RegExp(
    r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number (starts with 6-9)';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Min 8 chars, 1 number, 1 special char (!@#\$&*~)';
    }
    return null;
  }

  static String? validateFlatNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Flat number is required';
    }
    if (!_alphanumericRegex.hasMatch(value)) {
      return 'Alphanumeric characters only';
    }
    return null;
  }

  static String? validateVehicleNumber(String? value) {
    if (value != null && value.isNotEmpty) {
       // Normalize to uppercase before validation check if needed,
       // but validator just checks the format.
       if (!_vehicleRegex.hasMatch(value.toUpperCase())) {
         return 'Enter valid vehicle number (e.g. KA05AB1234)';
       }
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }
}
