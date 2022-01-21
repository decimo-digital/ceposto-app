import 'package:ceposto/models/user.dart';

class UserResponse {
  final List<User> user;

  UserResponse({this.user});

  factory UserResponse.fromJson(List<dynamic> json) => UserResponse(
        user: json.map((user) => User.fromJson(user)).toList(),
      );
}
