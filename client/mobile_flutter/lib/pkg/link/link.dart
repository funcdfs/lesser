// 深层链接公共组件导出
//
// 统一的内容链接系统，支持 URL 解析、元数据获取和卡片渲染
//
// 使用方式:
// 1. 使用 LinkParser.parse() 解析 URL 为 LinkModel
// 2. 使用 LinkResolver 获取链接元数据
// 3. 使用 LinkService 全局导航服务
// 4. 使用 LinkCard 渲染链接预览卡片
// 5. 使用 ChannelCard 显示频道名片

export 'models/models.dart';
export 'widgets/widgets.dart';
export 'link_parser.dart';
export 'link_resolver.dart';
export 'link_navigator.dart';
export 'link_service.dart';
export 'link_mock_data_source.dart';
