import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/shadcn_theme.dart';

class ShadcnAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fallbackInitials;
  final double size;

  const ShadcnAvatar({
    super.key,
    this.avatarUrl,
    required this.fallbackInitials,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ShadcnColors.secondary,
        border: Border.all(color: ShadcnColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias, // Important for SVG content
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _buildFallback();
    }

    if (avatarUrl!.endsWith('.svg') || avatarUrl!.contains('avataaars/svg')) {
      return SvgPicture.network(
        avatarUrl!,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _buildFallback(),
      );
    }

    return Image.network(
      avatarUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        fallbackInitials.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: ShadcnColors.secondaryForeground,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
