// 频道标签模型

/// 频道标签
class ChannelTag {
  const ChannelTag({
    required this.id,
    required this.name,
    this.icon,
    this.channelCount = 0,
    this.isSelected = false,
  });

  final String id;
  final String name;
  final String? icon; // emoji 或图标名
  final int channelCount;
  final bool isSelected;

  ChannelTag copyWith({
    String? id,
    String? name,
    String? icon,
    int? channelCount,
    bool? isSelected,
  }) {
    return ChannelTag(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      channelCount: channelCount ?? this.channelCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
