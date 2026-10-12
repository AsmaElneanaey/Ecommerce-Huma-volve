class UserModel {
  final int id;
  final String email;
  final String name;
  final String role;
  final String avatar;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.avatar,
  });

  String get profilePictureUrl {
    if (avatar.isNotEmpty && (avatar.startsWith('http://') || avatar.startsWith('https://'))) {
      return avatar;
    }
    return 'https://i.pravatar.cc/300';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      role: json['role'] as String? ?? 'customer',
      avatar: json['avatar'] as String? ?? 'https://i.pravatar.cc/300',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'avatar': avatar,
    };
  }
}
