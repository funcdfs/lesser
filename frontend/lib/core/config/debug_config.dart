/// 调试配置文件
///
/// 负责：
/// - 定义调试模式
/// - 提供调试相关的工具函数
/// - 配置fake数据
class DebugConfig {
  DebugConfig._();

  /// 是否启用纯前端调试模式
  static const bool debugLocal = true;

  /// 是否启用前后端联动调试模式
  static const bool debugRemote = false;
}
