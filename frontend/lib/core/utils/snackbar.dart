import 'package:flutter/material.dart';

/// Custom SnackBar utility for consistent error and success messages
class CustomSnackBar {
  /// Creates an error SnackBar with red styling
  static SnackBar error({required String message}) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFFF5252),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 3),
    );
  }

  /// Creates a success SnackBar with green styling
  static SnackBar success({required String message}) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF4CAF50),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 3),
    );
  }

  /// Creates an info SnackBar with blue styling
  static SnackBar info({required String message}) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF2196F3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 3),
    );
  }
}
