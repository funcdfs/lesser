// =============================================================================
// copyWith 工具函数
// =============================================================================
//
// 提供 copyWith 方法中常用的工具函数和哨兵值。
//
// ## 哨兵值模式
//
// Dart 的 copyWith 方法存在一个常见问题：无法区分 "未传参" 和 "传入 null"。
// 使用哨兵值模式可以解决这个问题：
//
// ```dart
// // 不传参：保留原值
// model.copyWith()
//
// // 传入 null：清除字段
// model.copyWith(optionalField: null)
//
// // 传入具体值：更新字段
// model.copyWith(optionalField: 'new value')
// ```
//
// ## 使用示例
//
// ```dart
// class MyModel {
//   final String? optionalField;
//
//   MyModel copyWith({Object? optionalField = sentinel}) {
//     return MyModel(
//       optionalField: optionalField == sentinel
//           ? this.optionalField
//           : castOrNull<String>(optionalField),
//     );
//   }
// }
// ```

/// 用于 copyWith 方法中区分 null 和未传参的哨兵值
///
/// 使用 `Object()` 作为哨兵值，因为它是唯一的实例，不会与任何有效值冲突。
const Object sentinel = _Sentinel();

/// 哨兵值的私有实现类
///
/// 使用私有类而非 `Object()` 可以：
/// 1. 提供更好的调试信息
/// 2. 避免与其他 Object 实例混淆
class _Sentinel {
  const _Sentinel();

  @override
  String toString() => 'sentinel (copyWith 哨兵值)';
}

/// 安全类型转换辅助方法
///
/// 将 `Object?` 转换为目标类型 `T?`。
///
/// - 如果 [value] 为 null，返回 null
/// - 如果 [value] 是目标类型 T，返回转换后的值
/// - 如果类型不匹配，在 debug 模式下抛出断言错误，release 模式下返回 null
///
/// ## 使用示例
///
/// ```dart
/// // 在 copyWith 中使用
/// optionalField: optionalField == sentinel
///     ? this.optionalField
///     : castOrNull<String>(optionalField),
/// ```
T? castOrNull<T>(Object? value) {
  if (value == null) return null;
  if (value is T) return value as T;

  // debug 模式下抛出断言错误，帮助开发者发现类型错误
  assert(
    false,
    'castOrNull: 期望类型 $T，实际类型 ${value.runtimeType}。'
    '请检查 copyWith 调用是否传入了正确的类型。',
  );

  return null;
}

/// 检查值是否为哨兵值
///
/// 用于在 copyWith 方法中判断参数是否被显式传入。
bool isSentinel(Object? value) => value is _Sentinel;
