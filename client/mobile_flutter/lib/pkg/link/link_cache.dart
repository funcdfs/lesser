// 链接元数据缓存
//
// 缓存链接的元数据，避免重复请求

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'models/link_model.dart';
import 'link_resolver.dart';

/// 缓存条目
class _CacheEntry {
  _CacheEntry({required this.metadata, required this.timestamp});

  final LinkMetadata metadata;
  final DateTime timestamp;

  /// 检查是否过期
  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

/// 链接元数据缓存
///
/// 提供内存缓存，避免重复请求链接元数据
class LinkMetadataCache {
  LinkMetadataCache({
    this.maxSize = 100,
    this.ttl = const Duration(minutes: 5),
  });

  /// 最大缓存条目数
  final int maxSize;

  /// 缓存过期时间
  final Duration ttl;

  /// 缓存存储
  final Map<String, _CacheEntry> _cache = {};

  /// 正在进行的请求（防止重复请求）
  final Map<String, Future<LinkMetadata>> _pendingRequests = {};

  /// 获取缓存的元数据
  ///
  /// 如果缓存命中且未过期，返回缓存的元数据
  /// 否则返回 null
  LinkMetadata? get(String url) {
    final entry = _cache[url];
    if (entry == null) return null;

    // 检查是否过期
    if (entry.isExpired(ttl)) {
      _cache.remove(url);
      return null;
    }

    return entry.metadata;
  }

  /// 设置缓存
  void set(String url, LinkMetadata metadata) {
    // 如果缓存已满，移除最旧的条目
    if (_cache.length >= maxSize) {
      _evictOldest();
    }

    _cache[url] = _CacheEntry(metadata: metadata, timestamp: DateTime.now());
  }

  /// 获取或加载元数据
  ///
  /// 如果缓存命中，返回缓存的元数据
  /// 否则调用 loader 加载并缓存
  Future<LinkMetadata> getOrLoad(
    String url,
    Future<LinkMetadata> Function() loader,
  ) async {
    // 检查缓存
    final cached = get(url);
    if (cached != null) return cached;

    // 检查是否有正在进行的请求
    final pending = _pendingRequests[url];
    if (pending != null) return pending;

    // 创建新请求
    final future = loader()
        .then((metadata) {
          set(url, metadata);
          _pendingRequests.remove(url);
          return metadata;
        })
        .catchError((e) {
          _pendingRequests.remove(url);
          throw e;
        });

    _pendingRequests[url] = future;
    return future;
  }

  /// 移除缓存条目
  void remove(String url) {
    _cache.remove(url);
  }

  /// 清空缓存
  void clear() {
    _cache.clear();
    _pendingRequests.clear();
  }

  /// 移除过期条目
  void removeExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired(ttl));
  }

  /// 移除最旧的条目
  void _evictOldest() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.timestamp.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.timestamp;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// 缓存大小
  int get size => _cache.length;

  /// 是否为空
  bool get isEmpty => _cache.isEmpty;

  /// 是否包含指定 URL
  bool contains(String url) => _cache.containsKey(url);
}

/// 带缓存的链接解析器
///
/// 包装 LinkResolver，添加缓存功能
class CachedLinkResolver implements LinkResolver {
  CachedLinkResolver({required this.resolver, LinkMetadataCache? cache})
    : cache = cache ?? LinkMetadataCache();

  /// 原始解析器
  final LinkResolver resolver;

  /// 缓存
  final LinkMetadataCache cache;

  @override
  Future<LinkMetadata> resolve(LinkModel link) {
    return cache.getOrLoad(link.url, () => resolver.resolve(link));
  }

  @override
  Future<String?> resolveCommentRoot(String commentId) {
    // 评论根节点不缓存，因为可能会变化
    return resolver.resolveCommentRoot(commentId);
  }

  /// 预加载链接元数据
  Future<void> preload(List<String> urls) async {
    if (kDebugMode) {
      debugPrint(
        '[Link] preload is disabled. urls=${urls.length}',
      );
    }
    return;
  }

  /// 使缓存失效
  void invalidate(String url) {
    cache.remove(url);
  }

  /// 清空缓存
  void clearCache() {
    cache.clear();
  }
}
