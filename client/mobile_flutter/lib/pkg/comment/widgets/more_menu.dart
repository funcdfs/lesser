// 更多菜单
//
// 弹出菜单：录制音频、启用链接预览
// 后续补充真正的功能

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';

/// 更多菜单项
enum MoreMenuItem {
  recordAudio(Icons.mic_rounded, '录制音频'),
  linkPreview(Icons.link_rounded, '启用链接预览');

  const MoreMenuItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// 显示更多菜单
///
/// 在按钮上方弹出菜单
Future<MoreMenuItem?> showMoreMenu(
  BuildContext context,
  Offset position,
) {
  final colors = AppColors.of(context);

  return showMenu<MoreMenuItem>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx - 160,
      position.dy - 110,
      position.dx,
      position.dy,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: colors.surfaceElevated,
    elevation: 8,
    items: MoreMenuItem.values.map((item) {
      return PopupMenuItem<MoreMenuItem>(
        value: item,
        height: 44,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
