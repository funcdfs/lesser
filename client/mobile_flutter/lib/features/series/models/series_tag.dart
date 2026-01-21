// =============================================================================
// 剧集标签模型
// =============================================================================
//
// 用于剧集分类筛选的标签数据模型。
//
// ## 设计说明
//
// - 标签本身是不可变的纯数据对象
// - 选中状态由 UI 层管理（使用 `Set<String>` 存储选中的标签 ID）
// - 这种设计使标签数据可以被多个 UI 组件共享，而不会产生状态冲突
//
// ## 使用示例
//
// ```dart
// // 定义标签
// const tag = SeriesTag(id: '1', name: '科幻', icon: '👽');
//
// // UI 层管理选中状态
// final selectedTagIds = <String>{};
// selectedTagIds.add(tag.id);  // 选中
// selectedTagIds.remove(tag.id);  // 取消选中
// ```

import '../../../pkg/utils/copy_with_utils.dart';

/// 剧集标签
///
/// 表示剧集的分类标签，用于筛选和组织剧集列表。
/// 每个标签包含唯一标识、显示名称、可选图标和关联的剧集数量。
class SeriesTag {
  /// 创建剧集标签
  ///
  /// - [id] 标签唯一标识
  /// - [name] 标签显示名称
  /// - [icon] 可选的 emoji 图标（如 '👽'、'🎬'）
  /// - [seriesCount] 使用该标签的剧集数量，默认为 0
  const SeriesTag({
    required this.id,
    required this.name,
    this.icon,
    this.seriesCount = 0,
  });

  /// 标签唯一标识
  final String id;

  /// 标签显示名称
  final String name;

  /// 可选的 emoji 图标
  ///
  /// 用于在 UI 中增强视觉识别度，如 '👽' 表示科幻、'🎬' 表示剧情
  final String? icon;

  /// 使用该标签的剧集数量
  ///
  /// 用于在 UI 中显示标签的热度或相关性
  final int seriesCount;

  /// 复制并修改指定字段
  ///
  /// 对于可选字段（如 `icon`），使用哨兵值模式：
  /// - 不传参：保留原值
  /// - 传入 `null`：清除该字段
  /// - 传入具体值：更新为新值
  SeriesTag copyWith({
    String? id,
    String? name,
    Object? icon = sentinel,
    int? seriesCount,
  }) {
    return SeriesTag(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon == sentinel ? this.icon : castOrNull<String>(icon),
      seriesCount: seriesCount ?? this.seriesCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SeriesTag && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SeriesTag(id: $id, name: $name, icon: $icon)';
}
