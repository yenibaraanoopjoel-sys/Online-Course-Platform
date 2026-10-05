class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final regex = RegExp(r'^\+?[\d\s\-]{7,15}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final n = num.tryParse(value.trim());
    if (n == null || n < 0) return '$fieldName must be a positive number';
    return null;
  }

  static String? lessonOrder(String? value) {
    if (value == null || value.trim().isEmpty) return 'Order is required';
    final n = int.tryParse(value.trim());
    if (n == null || n < 1) return 'Order must be a positive integer';
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) return 'Enter a valid URL';
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length < min) return '$fieldName must be at least $min characters';
    return null;
  }
}
