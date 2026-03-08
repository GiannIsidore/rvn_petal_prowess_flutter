class User {
  final int id;
  final String username;
  final String? createdAt;

  User({required this.id, required this.username, this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      username: json['username'] ?? '',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'created_at': createdAt};
  }
}
