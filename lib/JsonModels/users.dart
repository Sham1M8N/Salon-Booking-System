class Users {
  final int? userId;
  final String name;
  final String email;
  final String phone;
  final String username;
  final String password;

  Users({
    this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
  });

  // Factory constructor to create a Users object from a Map
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      userId: map['userId'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      username: map['username'],
      password: map['password'],
    );
  }

  // Method to convert a Users object to a Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'username': username,
      'password': password,
    };
  }
}