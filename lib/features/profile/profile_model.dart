class StudentProfile {
  final int userId;
  final String name;
  final String? school;
  final String? major;
  final List<String> skills;
  final String? availableTime;

  StudentProfile({
    required this.userId,
    required this.name,
    required this.school,
    required this.major,
    required this.skills,
    required this.availableTime,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> j) {
    final rawSkills = j['skills'];
    final skills = (rawSkills is List)
        ? rawSkills.map((e) => e.toString()).toList()
        : <String>[];

    return StudentProfile(
      userId: (j['user_id'] as num).toInt(),
      name: (j['name'] as String?) ?? '',
      school: j['school'] as String?,
      major: j['major'] as String?,
      skills: skills,
      availableTime: j['available_time'] as String?,
    );
  }
}
