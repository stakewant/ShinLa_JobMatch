enum ApplicationStatus { REQUESTED, ACCEPTED, REJECTED }

class ApplicationOut {
  final int id;
  final int jobPostId;
  final int studentId;
  final int companyId;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final int? roomId;

  ApplicationOut({
    required this.id,
    required this.jobPostId,
    required this.studentId,
    required this.companyId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.roomId,
  });

  factory ApplicationOut.fromJson(Map<String, dynamic> json) {
    return ApplicationOut(
      id: json['id'],
      jobPostId: json['job_post_id'],
      studentId: json['student_id'],
      companyId: json['company_id'],
      status: ApplicationStatus.values.firstWhere(
            (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['created_at']),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'])
          : null,
      roomId: json['room_id'],
    );
  }
}
