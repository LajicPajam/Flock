class AuthUser {
  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePhotoUrl,
    this.major,
    this.academicYear,
    this.vibe,
    this.favoritePlaylist,
    this.gender,
    this.studentEmail,
    this.pendingStudentEmail,
    required this.isStudentVerified,
    this.verifiedSchoolName,
    this.studentVerifiedAt,
    this.studentVerificationExpiresAt,
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
  final String? major;
  final String? academicYear;
  final String? vibe;
  final String? favoritePlaylist;
  final String? gender;
  final String? studentEmail;
  final String? pendingStudentEmail;
  final bool isStudentVerified;
  final String? verifiedSchoolName;
  final DateTime? studentVerifiedAt;
  final DateTime? studentVerificationExpiresAt;
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
      major: json['major'] as String?,
      academicYear: json['academic_year'] as String?,
      vibe: json['vibe'] as String?,
      favoritePlaylist: json['favorite_playlist'] as String?,
      gender: json['gender'] as String?,
      studentEmail: json['student_email'] as String?,
      pendingStudentEmail: json['pending_student_email'] as String?,
      isStudentVerified: json['is_student_verified'] as bool? ?? false,
      verifiedSchoolName: json['verified_school_name'] as String?,
      studentVerifiedAt: json['student_verified_at'] == null
          ? null
          : DateTime.tryParse(json['student_verified_at'] as String),
      studentVerificationExpiresAt:
          json['student_verification_expires_at'] == null
          ? null
          : DateTime.tryParse(
              json['student_verification_expires_at'] as String,
            ),
      isDriver: json['is_driver'] as bool? ?? false,
      carMake: json['car_make'] as String?,
      carModel: json['car_model'] as String?,
      carColor: json['car_color'] as String?,
      carPlateState: json['car_plate_state'] as String?,
      carPlateNumber: json['car_plate_number'] as String?,
      carDescription: json['car_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_photo_url': profilePhotoUrl,
      'major': major,
      'academic_year': academicYear,
      'vibe': vibe,
      'favorite_playlist': favoritePlaylist,
      'gender': gender,
      'student_email': studentEmail,
      'pending_student_email': pendingStudentEmail,
      'is_student_verified': isStudentVerified,
      'verified_school_name': verifiedSchoolName,
      'student_verified_at': studentVerifiedAt?.toIso8601String(),
      'student_verification_expires_at':
          studentVerificationExpiresAt?.toIso8601String(),
      'is_driver': isDriver,
      'car_make': carMake,
      'car_model': carModel,
      'car_color': carColor,
      'car_plate_state': carPlateState,
      'car_plate_number': carPlateNumber,
      'car_description': carDescription,
    };
  }
}
