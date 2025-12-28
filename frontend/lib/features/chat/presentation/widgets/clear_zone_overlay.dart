import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

/// 清除区域覆盖层
/// 
/// 在拖拽未读圆点时显示，提示用户拖拽到中间可清除所有未读
class ClearZoneOverlay extends StatelessWidget {
  /// 是否激活（圆点在清除区域内）
  final bool isActive;

  const ClearZoneOverlay({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Positioned(
      left: screenSize.width / 2 - 60,
      top: screenSize.height / 2 - 60,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? AppColors.destructive.withValues(alpha: 0.3)
              : AppColors.muted.withValues(alpha: 0.2),
          border: Border.all(
            color: isActive
                ? AppColors.destructive
                : AppColors.mutedForeground.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.check : Icons.delete_outline,
              color: isActive
                  ? AppColors.destructive
                  : AppColors.mutedForeground.withValues(alpha: 0.5),
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              isActive ? '松开清除' : '拖到这里',
              style: TextStyle(
                color: isActive
                    ? AppColors.destructive
                    : AppColors.mutedForeground.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
