import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegex.hasMatch(this);
  }
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as relative time (e.g., "2h ago", "3d ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (year == now.year) {
      return DateFormat('MMM d').format(this);
    } else {
      return DateFormat('MMM d, yyyy').format(this);
    }
  }

  /// Format as full date
  String get fullDate {
    return DateFormat('MMMM d, yyyy').format(this);
  }

  /// Format as time
  String get time {
    return DateFormat('h:mm a').format(this);
  }

  /// Format as date and time
  String get dateTime {
    return DateFormat('MMM d, yyyy h:mm a').format(this);
  }
}

/// Number extensions
extension NumberExtensions on num {
  /// Format as compact number (e.g., 1.2K, 3.4M)
  String get compact {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

/// BuildContext extensions
extension BuildContextExtensions on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}
