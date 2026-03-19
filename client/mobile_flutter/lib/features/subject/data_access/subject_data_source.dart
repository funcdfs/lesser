// =============================================================================
// 剧集数据源接口
// =============================================================================
//
// 定义剧集数据获取的抽象接口，支持多种实现（Mock、gRPC 等）。
//
// ## 设计目的
//
// 1. **依赖倒置**：Handler 层依赖抽象接口而非具体实现
// 2. **易于测试**：可以注入 Mock 实现进行单元测试
// 3. **平滑切换**：开发阶段使用 Mock，生产环境切换到 gRPC
//
// ## 实现类
//
// - `SeriesMockDataSource` - Mock 实现，用于开发和测试
// - `SeriesGrpcDataSource` - gRPC 实现，用于生产环境（待实现）

import '../models/subject_models.dart';

/// 剧集数据源接口
///
/// 抽象剧集相关的数据获取逻辑，便于切换不同的数据源实现。
abstract class SubjectDataSource {
  /// 获取剧集列表
  ///
  /// 返回当前用户订阅的所有剧集。
  Future<List<SubjectModel>> getSubjectList();

  /// 获取剧集 UI 状态
  ///
  /// 返回所有剧集的 UI 状态（未读数、静音、置顶等）。
  /// 用于初始化剧集列表的 UI 状态。
  Future<Map<String, SubjectUIState>> getUIStates();

  /// 获取剧集详情
  ///
  /// 根据剧集 ID 获取完整的剧集信息，包括置顶动态等。
  /// 如果剧集不存在，返回 null。
  Future<SubjectModel?> getSubjectDetail(String id);

  /// 获取剧集话题列表
  ///
  /// 返回指定剧集的话题列表（用于 Discord 模式）。
  Future<List<SubjectTopicModel>> getTopics(String subjectId);

  /// 获取剧集动态列表
  ///
  /// 返回指定剧集的动态列表，按时间升序排列（最新在底部）。
  /// 可选 [topicId] 用于过滤特定话题的动态。
  Future<List<MessageModel>> getPosts(String subjectId, {String? topicId});

  /// 切换静音状态
  ///
  /// 静音后不会收到该剧集的推送通知，但仍会计算未读数。
  Future<void> toggleMute(String subjectId, bool muted);

  /// 切换置顶状态
  ///
  /// 置顶的剧集会在列表顶部显示。
  Future<void> togglePin(String subjectId, bool pinned);
}
