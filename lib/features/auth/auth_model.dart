enum UserRole { STUDENT, COMPANY, ADMIN }

UserRole userRoleFromString(String v) {
  return UserRole.values.firstWhere(
        (e) => e.name == v,
    orElse: () => UserRole.STUDENT,
  );
}

class UserOut {
  final int id;
  final String? email;
  final String? phone;
  final UserRole role;
  final bool isActive;

  UserOut({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
  });

  factory UserOut.fromJson(Map<String, dynamic> j) {
    return UserOut(
      id: (j['id'] as num).toInt(),
      email: j['email'] as String?,
      phone: j['phone'] as String?,
      role: userRoleFromString(j['role'] as String),
      isActive: (j['is_active'] as bool?) ?? true,
    );
  }
}

class TokenResponse {
  final String accessToken;
  final String tokenType;

  TokenResponse({required this.accessToken, required this.tokenType});

  factory TokenResponse.fromJson(Map<String, dynamic> j) {
    return TokenResponse(
      accessToken: j['access_token'] as String,
      tokenType: j['token_type'] as String,
    );
  }
}
