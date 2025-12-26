/// Validation rules and constants
class ValidationRules {
  // Email validation
  static const int minEmailLength = 5;
  static const int maxEmailLength = 254;

  // Username validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  // Password validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Post content validation
  static const int minPostContentLength = 1;
  static const int maxPostContentLength = 5000;

  // Regular expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&'
    "'"
    r'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d@$!%*?&_.-]{8,}$',
  );

  // Private constructor to prevent instantiation
  ValidationRules._();
}
