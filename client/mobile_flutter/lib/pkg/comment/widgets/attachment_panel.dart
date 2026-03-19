// 附件面板 Shell
//
// Telegram 风格的半屏附件选择面板
// 后续补充真正的文件选择功能

import 'package:flutter/material.dart';
import '../../ui/theme/theme.dart';

/// 附件类型
enum _AttachmentTab {
  gallery(Icons.photo_library_rounded, '相册'),
  file(Icons.insert_drive_file_rounded, '文件'),
  location(Icons.location_on_rounded, '位置'),
  poll(Icons.poll_rounded, '投票');

  const _AttachmentTab(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// 显示附件面板（BottomSheet）
Future<void> showAttachmentPanel(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AttachmentPanel(),
  );
}

/// 附件面板
class _AttachmentPanel extends StatefulWidget {
  const _AttachmentPanel();

  @override
  State<_AttachmentPanel> createState() => _AttachmentPanelState();
}

class _AttachmentPanelState extends State<_AttachmentPanel> {
  _AttachmentTab _selectedTab = _AttachmentTab.gallery;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.5,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          _DragHandle(colors: colors),
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  _selectedTab.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 内容区域
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedTab.icon,
                    size: 48,
                    color: colors.textDisabled,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_selectedTab.label}功能开发中',
                    style: TextStyle(fontSize: 14, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          // 底部 tab
          SafeArea(
            top: false,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.divider, width: 0.5),
                ),
              ),
              child: Row(
                children: _AttachmentTab.values.map((tab) {
                  final isSelected = tab == _selectedTab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tab.icon,
                            size: 22,
                            color: isSelected
                                ? colors.accent
                                : colors.textDisabled,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? colors.accent
                                  : colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 拖拽指示器
class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.colors});

  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: colors.textDisabled.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
