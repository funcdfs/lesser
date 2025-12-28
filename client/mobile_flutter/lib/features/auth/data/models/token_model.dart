/// Token data model
class TokenModel {
  /// Create from JSON
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
  const TokenModel({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}
