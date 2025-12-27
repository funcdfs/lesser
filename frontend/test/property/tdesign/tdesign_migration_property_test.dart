import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Property-based tests for TDesign UI Unification
/// Feature: tdesign-ui-unification
///
/// These tests verify that the migration to TDesign is complete and consistent.

void main() {
  group('Property 1: No Legacy UI Imports', () {
    /// **Feature: tdesign-ui-unification, Property 1: No Legacy UI Imports**
    /// **Validates: Requirements 1.2, 4.3, 10.1**
    ///
    /// *For any* Dart file in the `frontend/lib` directory, the file SHALL NOT
    /// contain imports from `forui` package or usage of `FTextField`, `FButton`,
    /// or other forui components.
    test('No forui imports in lib directory', () {
      final libDir = Directory('lib');
      if (!libDir.existsSync()) {
        fail('lib directory does not exist');
      }

      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      final violations = <String>[];
      final foruiPatterns = [
        RegExp(r'''import\s+['"]package:forui'''),
        RegExp(r'''import\s+['"]forui'''),
        RegExp(r'\bFTextField\b'),
        RegExp(r'\bFButton\b'),
        RegExp(r'\bFDialog\b'),
        RegExp(r'\bFCard\b'),
        RegExp(r'\bFScaffold\b'),
        RegExp(r'\bFHeader\b'),
        RegExp(r'\bFTabs\b'),
        RegExp(r'\bFSwitch\b'),
        RegExp(r'\bFCheckbox\b'),
        RegExp(r'\bFRadio\b'),
        RegExp(r'\bFSlider\b'),
        RegExp(r'\bFProgress\b'),
        RegExp(r'\bFBadge\b'),
        RegExp(r'\bFAvatar\b'),
        RegExp(r'\bFIcon\b'),
        RegExp(r'\bFDivider\b'),
        RegExp(r'\bFLabel\b'),
        RegExp(r'\bFTheme\b'),
      ];

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          for (final pattern in foruiPatterns) {
            if (pattern.hasMatch(line)) {
              violations.add(
                '${file.path}:${i + 1}: Found forui reference: "${line.trim()}"',
              );
            }
          }
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'Found ${violations.length} forui references that should be removed:\n'
          '${violations.take(20).join('\n')}'
          '${violations.length > 20 ? '\n... and ${violations.length - 20} more' : ''}',
        );
      }
    });

    test('No forui package in pubspec.yaml', () {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) {
        fail('pubspec.yaml does not exist');
      }

      final content = pubspecFile.readAsStringSync();
      final foruiDependencyPattern = RegExp(r'^\s*forui:', multiLine: true);

      expect(
        foruiDependencyPattern.hasMatch(content),
        isFalse,
        reason: 'pubspec.yaml should not contain forui dependency',
      );
    });
  });

  group('Property 2: No Hardcoded Colors in UI Components', () {
    /// **Feature: tdesign-ui-unification, Property 2: No Hardcoded Colors in UI Components**
    /// **Validates: Requirements 2.7, 10.3**
    ///
    /// *For any* Dart file in the `frontend/lib/features` or `frontend/lib/shared/widgets`
    /// directories, the file SHALL NOT contain hardcoded color values outside of
    /// the theme definition files.
    test('No hardcoded colors in features directory', () {
      _checkNoHardcodedColors('lib/features');
    });

    test('No hardcoded colors in shared/widgets directory', () {
      _checkNoHardcodedColors('lib/shared/widgets');
    });
  });
}

/// Helper function to check for hardcoded colors in a directory
void _checkNoHardcodedColors(String dirPath) {
  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    fail('$dirPath directory does not exist');
  }

  final dartFiles = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  final violations = <String>[];

  // Patterns for hardcoded colors
  final hardcodedColorPatterns = [
    // Color(0xFF...) pattern - hex colors
    RegExp(r'Color\s*\(\s*0x[0-9A-Fa-f]{8}\s*\)'),
    // Colors.xxx pattern - Material colors (must not be preceded by 'App')
    // Excluding Colors.transparent and Colors.white/black which are sometimes acceptable
    RegExp(
        r'(?<!App)Colors\.(red|blue|green|yellow|orange|purple|pink|teal|cyan|amber|indigo|lime|brown|grey|blueGrey)\b'),
    // Color.fromRGBO pattern
    RegExp(r'Color\.fromRGBO\s*\('),
    // Color.fromARGB pattern
    RegExp(r'Color\.fromARGB\s*\('),
  ];

  // Files to exclude from checking (theme definition files)
  final excludedFiles = [
    'colors.dart',
    'theme.dart',
    'app_theme.dart',
    'spacing.dart',
  ];

  for (final file in dartFiles) {
    final fileName = file.path.split('/').last;

    // Skip theme definition files
    if (excludedFiles.contains(fileName)) {
      continue;
    }

    final content = file.readAsStringSync();
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip comments
      if (line.trim().startsWith('//') || line.trim().startsWith('*')) {
        continue;
      }

      for (final pattern in hardcodedColorPatterns) {
        final matches = pattern.allMatches(line);
        for (final match in matches) {
          // Check if this is inside a comment
          final beforeMatch = line.substring(0, match.start);
          if (beforeMatch.contains('//')) {
            continue;
          }

          violations.add(
            '${file.path}:${i + 1}: Found hardcoded color: "${match.group(0)}"',
          );
        }
      }
    }
  }

  if (violations.isNotEmpty) {
    fail(
      'Found ${violations.length} hardcoded colors that should use AppColors:\n'
      '${violations.take(20).join('\n')}'
      '${violations.length > 20 ? '\n... and ${violations.length - 20} more' : ''}',
    );
  }
}
