import '../constants/app_constants.dart';

/// Input validation utilities
class Validators {
  Validators._();

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length > AppConstants.maxUsernameLength) {
      return 'Username must be ${AppConstants.maxUsernameLength} characters or less';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validate display name
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }
    if (value.length > 50) {
      return 'Display name must be 50 characters or less';
    }
    return null;
  }

  /// Validate bio
  static String? validateBio(String? value) {
    if (value != null && value.length > AppConstants.maxBioLength) {
      return 'Bio must be ${AppConstants.maxBioLength} characters or less';
    }
    return null;
  }

  /// Validate short post content
  static String? validateShortPost(String? value) {
    if (value == null || value.isEmpty) {
      return 'Post content is required';
    }
    if (value.length > AppConstants.maxShortPostLength) {
      return 'Post must be ${AppConstants.maxShortPostLength} characters or less';
    }
    return null;
  }

  /// Validate column title
  static String? validateColumnTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > AppConstants.maxColumnTitleLength) {
      return 'Title must be ${AppConstants.maxColumnTitleLength} characters or less';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
