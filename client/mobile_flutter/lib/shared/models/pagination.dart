import 'package:equatable/equatable.dart';

/// 分页模型
class Pagination extends Equatable {
  const Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// 从 JSON 创建
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
    );
  }

  final int page;
  final int pageSize;
  final int total;

  /// 总页数
  int get totalPages => (total / pageSize).ceil();

  /// 是否有更多页
  bool get hasMore => page < totalPages;

  /// 是否是第一页
  bool get isFirst => page == 1;

  /// 是否是最后一页
  bool get isLast => page >= totalPages;

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'page': page, 'page_size': pageSize, 'total': total};
  }

  /// 创建下一页分页
  Pagination nextPage() {
    return Pagination(page: page + 1, pageSize: pageSize, total: total);
  }

  @override
  List<Object?> get props => [page, pageSize, total];
}

/// 分页响应包装器
class PaginatedResponse<T> extends Equatable {
  const PaginatedResponse({required this.items, required this.pagination});

  final List<T> items;
  final Pagination pagination;

  @override
  List<Object?> get props => [items, pagination];
}
