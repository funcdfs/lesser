import 'package:equatable/equatable.dart';

/// Pagination model
class Pagination extends Equatable {
  const Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final int page;
  final int pageSize;
  final int total;

  /// Total number of pages
  int get totalPages => (total / pageSize).ceil();

  /// Whether there are more pages
  bool get hasMore => page < totalPages;

  /// Whether this is the first page
  bool get isFirst => page == 1;

  /// Whether this is the last page
  bool get isLast => page >= totalPages;

  /// Create from JSON
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'total': total,
    };
  }

  /// Create next page pagination
  Pagination nextPage() {
    return Pagination(
      page: page + 1,
      pageSize: pageSize,
      total: total,
    );
  }

  @override
  List<Object?> get props => [page, pageSize, total];
}

/// Paginated response wrapper
class PaginatedResponse<T> extends Equatable {
  const PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final Pagination pagination;

  @override
  List<Object?> get props => [items, pagination];
}
