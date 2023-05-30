class User {
  final String id;
  final String name;
  final String email;
  final bool isDoctor;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isDoctor,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      isDoctor: json['isDoctor'],
    );
  }
}
