class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final bool isMerchant;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.isMerchant,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
          id: json['id'],
          firstName: json['firstName'],
          lastName: json['lastName'],
          email: json['email'],
          isMerchant: json['merchant']);
    } catch (e) {
      print('[User-fromJson] Failed to parse user: $e');
      rethrow;
    }
  }
}
