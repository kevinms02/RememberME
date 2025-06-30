class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final String? profilePicture;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'profilePicture': profilePicture,
    };
  }
}