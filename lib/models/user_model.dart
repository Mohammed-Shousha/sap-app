class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isDoctor;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isDoctor,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      isDoctor: json['isDoctor'],
    );
  }
}
