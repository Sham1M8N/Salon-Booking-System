class Administrator {
  final int? adminId;
  final String username;
  final String password;

  Administrator({
    this.adminId,
    required this.username,
    required this.password,
  });

  // Factory constructor to create an Administrator object from a Map
  factory Administrator.fromMap(Map<String, dynamic> map) {
    return Administrator(
      adminId: map['adminId'],
      username: map['username'],
      password: map['password'],
    );
  }

  // Method to convert an Administrator object to a Map
  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'username': username,
      'password': password,
    };
  }
}
