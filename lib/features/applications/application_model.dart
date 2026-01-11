enum ApplicationStatus { PENDING, ACCEPTED, REJECTED }

class ApplicationOut {
  final int id;
  final int jobPostId;
  final int companyId;
  final int studentId;
  final ApplicationStatus status;
  final DateTime createdAt;

  /// ACCEPTED면 roomId가 생긴다고 가정(서버 붙이면 서버 값으로 교체)
  final int? roomId;

  ApplicationOut({
    required this.id,
    required this.jobPostId,
    required this.companyId,
    required this.studentId,
    required this.status,
    required this.createdAt,
    required this.roomId,
  });

  ApplicationOut copyWith({
    ApplicationStatus? status,
    int? roomId,
  }) {
    return ApplicationOut(
      id: id,
      jobPostId: jobPostId,
      companyId: companyId,
      studentId: studentId,
      status: status ?? this.status,
      createdAt: createdAt,
      roomId: roomId ?? this.roomId,
    );
  }
}
