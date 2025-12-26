import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lesser/core/config/debug_config.dart';
import 'package:lesser/features/search/domain/models/hot_item.dart';
import 'package:lesser/features/search/presentation/providers/search_provider.dart';

part 'hot_content_provider.g.dart';

/// Provider for hot list items
@riverpod
Future<List<HotItem>> hotList(Ref ref) async {
  if (DebugConfig.debugLocal) {
    // Debug mode: return mock data
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      HotItem(
        title: '简单又健康的早餐食谱合集',
        author: 'Sarah Chen',
        heat: '1256 热度',
        imageUrl:
            'https://tiebapic.baidu.com/forum/pic/item/8326cffc1e178a82d6199320f303738da977e8ea.jpg',
      ),
      HotItem(
        title: '家居收纳技巧大公开',
        author: 'Alex Rivera',
        heat: '2341 热度',
        imageUrl:
            'https://tiebapic.baidu.com/forum/pic/item/bba1cd11728b47103e6834b9cfcec3fdfd0323ea.jpg',
      ),
      HotItem(
        title: '亲子旅行目的地推荐',
        author: 'Maya Patel',
        heat: '3456 热度',
        imageUrl:
            'https://tiebapic.baidu.com/forum/pic/item/7aec54e736d12f2ea06efb0449c2d562853568ea.jpg',
      ),
      HotItem(
        title: '护肤步骤详解：从清洁到保养',
        author: 'Emma Wilson',
        heat: '1890 热度',
        imageUrl:
            'https://tiebapic.baidu.com/forum/pic/item/d62a6059252dd42ad1f4f5a3063b5bb5c8eab8ea.jpg',
      ),
      HotItem(
        title: 'DIY手工：制作个性化笔记本',
        author: 'David Kim',
        heat: '987 热度',
        imageUrl:
            'https://tiebapic.baidu.com/forum/pic/item/a8014c086e061d9539d09c3e7ef40ad162d9caea.jpg',
      ),
    ];
  } else {
    final repository = ref.watch(searchRepositoryProvider);
    return repository.getHotList();
  }
}

/// Provider for hot tags
@riverpod
Future<List<String>> hotTags(Ref ref) async {
  if (DebugConfig.debugLocal) {
    // Debug mode: return mock data
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      '旅行',
      '美食',
      '摄影',
      '艺术',
      '音乐',
      '电影',
      '读书',
      '健身',
      '科技',
      '设计',
    ];
  } else {
    final repository = ref.watch(searchRepositoryProvider);
    return repository.getHotTags();
  }
}

/// Provider for category filters
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => '全局热门';

  void setCategory(String category) {
    state = category;
  }
}

/// Available category filters
const List<String> categoryFilters = ['全局热门', '旅游', '美食', '科技'];
