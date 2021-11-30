class ResponseLog {
  final String accessToken;
  final String refreshToken;

  ResponseLog({this.accessToken, this.refreshToken});

  factory ResponseLog.fromJson(Map<String, dynamic> json) {
    return ResponseLog(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String);
  }
}
