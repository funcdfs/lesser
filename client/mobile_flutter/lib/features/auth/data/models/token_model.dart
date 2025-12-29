/// Token 数据模型
class TokenModel {
  const TokenModel({required this.accessToken, required this.refreshToken});

  /// 从 JSON 创建
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  final String accessToken;
  final String refreshToken;

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}
