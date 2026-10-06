class UserModel {
  final String uid;
  final String email;
  final String name;
  final String mobile;
  final String role;
  final String idToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.mobile = '',
    this.role = 'student',
    this.idToken = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'mobile': mobile,
      'role': role,
      'idToken': idToken,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? 'student',
      idToken: json['idToken'] ?? '',
    );
  }
}
