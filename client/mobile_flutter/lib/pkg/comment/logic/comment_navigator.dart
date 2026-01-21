// 评论页面导航管理器
//
// 管理评论页面栈，处理页面间导航逻辑：
// - 页面栈管理（根总览层、子层、新总览层）
// - replace/push 模式导航
// - 返回帖子功能
//
// 设计原则：
// - 与 UI 完全分离，只处理导航逻辑
// - 通过回调通知 UI 层执行具体操作

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// 评论页面状态接口
///
/// UI 层实现此接口，供导航器调用
abstract class CommentPageDelegate {
  /// 页面是否已挂载
  bool get mounted;

  /// 导航到指定评论（页面内跳转）
  void navigateToComment(String targetCommentId, {bool alignToBottom = false});

  /// 跳转到 header（瞬移）
  void jumpToHeader();
}

/// 评论页面导航管理器
///
/// 单例模式，管理全局评论页面栈
///
/// 注意：此类仅在主 isolate 中使用，不支持多 isolate 场景
class CommentNavigator {
  CommentNavigator._();

  static final CommentNavigator instance = CommentNavigator._();

  /// 页面栈
  final List<CommentPageDelegate> _pageStack = [];

  /// 页面栈长度
  int get stackLength => _pageStack.length;

  /// 是否有页面
  bool get hasPages => _pageStack.isNotEmpty;

  /// 获取根总览层
  CommentPageDelegate? get rootPage =>
      _pageStack.isNotEmpty ? _pageStack.first : null;

  /// 获取当前页面
  CommentPageDelegate? get currentPage =>
      _pageStack.isNotEmpty ? _pageStack.last : null;

  /// 注册页面到栈
  void registerPage(CommentPageDelegate page) {
    _pageStack.add(page);
    if (kDebugMode) {
      debugPrint('[CommentNavigator] register page=${page.runtimeType} size=${_pageStack.length}');
    }
  }

  /// 从栈中移除页面
  void unregisterPage(CommentPageDelegate page) {
    _pageStack.remove(page);
    if (kDebugMode) {
      debugPrint('[CommentNavigator] unregister page=${page.runtimeType} size=${_pageStack.length}');
    }
  }

  /// 判断是否是根总览层
  bool isRootPage(CommentPageDelegate page) {
    return _pageStack.isNotEmpty && _pageStack.first == page;
  }

  /// 判断是否应该显示"返回帖子"按钮
  bool shouldShowReturnButton(CommentPageDelegate page) {
    return _pageStack.length > 1 && !isRootPage(page);
  }

  /// 获取页面在栈中的索引
  int getPageIndex(CommentPageDelegate page) {
    return _pageStack.indexOf(page);
  }

  /// 页面内导航（replace 模式）
  ///
  /// 在当前页面内跳转到指定评论，不创建新页面
  /// 返回 true 表示成功，false 表示没有可用的评论页面
  bool navigateInPlace(String targetCommentId, {bool alignToBottom = false}) {
    if (_pageStack.isEmpty) return false;

    final currentPage = _pageStack.last;
    if (!currentPage.mounted) return false;

    currentPage.navigateToComment(
      targetCommentId,
      alignToBottom: alignToBottom,
    );
    if (kDebugMode) {
      debugPrint(
        '[CommentNavigator] navigateInPlace target=$targetCommentId alignToBottom=$alignToBottom',
      );
    }
    return true;
  }

  /// 返回帖子 - pop 所有子层和新总览层，回到根总览层
  ///
  /// [context] 当前页面的 BuildContext
  /// [currentPage] 当前页面的 delegate
  void returnToPost(BuildContext context, CommentPageDelegate currentPage) {
    if (_pageStack.isEmpty) return;

    // 获取根总览层的引用
    final rootState = _pageStack.first;

    // 计算需要 pop 的次数
    final currentIndex = _pageStack.indexOf(currentPage);
    if (currentIndex <= 0) return; // 已经是根总览层，不需要返回

    if (kDebugMode) {
      debugPrint('[CommentNavigator] returnToPost popCount=$currentIndex');
    }

    // 连续 pop 直到只剩根总览层
    int popCount = currentIndex;
    Navigator.popUntil(context, (route) {
      if (popCount <= 0) return true;
      popCount--;
      return false;
    });

    // 通知根总览层执行置顶（使用瞬移，与 Link 系统行为一致）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (rootState.mounted) {
        rootState.jumpToHeader();
      }
    });
  }

  /// 清空页面栈（用于测试或重置）
  @visibleForTesting
  void clear() {
    _pageStack.clear();
  }
}
