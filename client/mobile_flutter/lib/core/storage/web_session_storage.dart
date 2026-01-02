import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Web 会话存储包装器（存根实现）
/// 
/// 在移动平台上，这个类只是返回标准的 FlutterSecureStorage。
/// Web 平台的实际实现需要使用条件导入。
/// 
/// 由于我们主要针对移动端，这里提供一个简单的存根实现。
class WebSessionStorage extends FlutterSecureStorage {
  const WebSessionStorage() : super();
  
  // 在移动平台上，直接使用父类的实现
  // Web 平台需要单独处理
}
