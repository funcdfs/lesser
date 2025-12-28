import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/theme.dart';

/// 未读消息圆点组件
/// 
/// 显示一个代表总未读数量的圆点，支持：
/// - 点击：循环跳转到未读消息列表（从早到晚）
/// - 长按拖拽到屏幕中间：清除所有未读
/// 
/// 视觉规格：
/// - 圆点大小：12x12px
/// - 颜色：[AppColors.destructive]
/// - 无未读时不显示
class UnreadDot extends StatefulWidget {
  /// 总未读数量
  final int unreadCount;
  
  /// 未读会话ID列表（按时间从早到晚排序）
  final List<String> unreadConversationIds;
  
  /// 点击跳转回调，参数为会话ID
  final void Function(String conversationId)? onJumpToConversation;
  
  /// 清除所有未读回调
  final VoidCallback? onClearAllUnread;
  
  /// 拖拽开始回调
  final VoidCallback? onDragStart;
  
  /// 拖拽更新回调，参数为是否在清除区域
  final void Function(bool isInClearZone)? onDragUpdate;
  
  /// 拖拽结束回调
  final VoidCallback? onDragEnd;

  const UnreadDot({
    super.key,
    required this.unreadCount,
    required this.unreadConversationIds,
    this.onJumpToConversation,
    this.onClearAllUnread,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  State<UnreadDot> createState() => _UnreadDotState();
}

class _UnreadDotState extends State<UnreadDot> with SingleTickerProviderStateMixin {
  /// 当前跳转索引
  int _currentIndex = 0;
  
  /// 是否正在拖拽
  bool _isDragging = false;
  
  /// 拖拽偏移量
  Offset _dragOffset = Offset.zero;
  
  /// 是否在清除区域
  bool _isInClearZone = false;
  
  /// 动画控制器
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(UnreadDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果未读列表变化，重置索引
    if (widget.unreadConversationIds.length != oldWidget.unreadConversationIds.length) {
      _currentIndex = 0;
    }
  }

  void _handleTap() {
    if (widget.unreadConversationIds.isEmpty) return;
    
    // 触发触觉反馈
    HapticFeedback.lightImpact();
    
    // 获取当前要跳转的会话ID
    final conversationId = widget.unreadConversationIds[_currentIndex];
    
    // 调用跳转回调
    widget.onJumpToConversation?.call(conversationId);
    
    // 循环更新索引
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.unreadConversationIds.length;
    });
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isDragging = true;
      _dragOffset = Offset.zero;
    });
    _animationController.forward();
    widget.onDragStart?.call();
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    setState(() {
      _dragOffset = details.offsetFromOrigin;
      
      // 检查是否在屏幕中间区域（清除区域）
      final screenSize = MediaQuery.of(context).size;
      final centerX = screenSize.width / 2;
      final centerY = screenSize.height / 2;
      
      // 获取当前组件的全局位置
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final globalPosition = box.localToGlobal(Offset.zero) + _dragOffset;
        
        // 清除区域：屏幕中心 100x100 的区域
        final clearZoneRadius = 80.0;
        final distance = (globalPosition - Offset(centerX, centerY)).distance;
        
        final wasInClearZone = _isInClearZone;
        _isInClearZone = distance < clearZoneRadius;
        
        // 进入清除区域时触发触觉反馈
        if (_isInClearZone && !wasInClearZone) {
          HapticFeedback.heavyImpact();
        }
        
        // 通知父组件更新清除区域状态
        widget.onDragUpdate?.call(_isInClearZone);
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (_isInClearZone) {
      // 在清除区域释放，清除所有未读
      HapticFeedback.heavyImpact();
      widget.onClearAllUnread?.call();
    }
    
    setState(() {
      _isDragging = false;
      _dragOffset = Offset.zero;
      _isInClearZone = false;
    });
    _animationController.reverse();
    widget.onDragEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.unreadCount == 0) {
      return const SizedBox.shrink();
    }

    return Transform.translate(
      offset: _dragOffset,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: _handleTap,
          onLongPressStart: _handleLongPressStart,
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          onLongPressEnd: _handleLongPressEnd,
          child: Semantics(
            label: '${widget.unreadCount}条未读消息，点击跳转，长按拖拽到中间清除',
            button: true,
            child: Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _isInClearZone 
                    ? AppColors.destructive.withValues(alpha: 0.5)
                    : AppColors.destructive,
                shape: BoxShape.circle,
                boxShadow: _isDragging
                    ? [
                        BoxShadow(
                          color: AppColors.destructive.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
