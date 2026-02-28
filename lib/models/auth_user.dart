class AuthUser {
  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePhotoUrl,
  });

  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePhotoUrl;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String? ?? '',
      profilePhotoUrl: json['profile_photo_url'] as String? ?? '',
    );
  }
}
