class AuthUser {
  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePhotoUrl,
    required this.isDriver,
    this.carMake,
    this.carModel,
    this.carColor,
    this.carPlateState,
    this.carPlateNumber,
    this.carDescription,
  });

  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePhotoUrl;
  final bool isDriver;
  final String? carMake;
  final String? carModel;
  final String? carColor;
  final String? carPlateState;
  final String? carPlateNumber;
  final String? carDescription;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String? ?? '',
      profilePhotoUrl: json['profile_photo_url'] as String? ?? '',
      isDriver: json['is_driver'] as bool? ?? false,
      carMake: json['car_make'] as String?,
      carModel: json['car_model'] as String?,
      carColor: json['car_color'] as String?,
      carPlateState: json['car_plate_state'] as String?,
      carPlateNumber: json['car_plate_number'] as String?,
      carDescription: json['car_description'] as String?,
    );
  }
}
