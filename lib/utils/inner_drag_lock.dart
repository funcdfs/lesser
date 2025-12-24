import 'package:flutter/foundation.dart';

/// A simple reference-counting lock used to indicate when an inner
/// horizontal scroll/drag is active. When one or more inner widgets
/// are dragging horizontally, `isDragging` becomes true so parent
/// scrollables (e.g. the TabBarView) can disable page swipes.
class InnerDragLock {
  InnerDragLock._();

  static final ValueNotifier<bool> isDragging = ValueNotifier<bool>(false);
  static int _count = 0;

  static void start() {
    _count++;
    if (_count == 1) isDragging.value = true;
  }

  static void end() {
    if (_count <= 0) return;
    _count--;
    if (_count == 0) isDragging.value = false;
  }
}
