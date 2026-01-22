class StudentDocument {
  final String type; // 'resume' | 'cover_letter'
  final String? localPath; // 앱에서 선택한 로컬 경로(업로드 전 단계)
  final String? filename;
  final String? url; // 서버 업로드 후 url

  StudentDocument({
    required this.type,
    this.localPath,
    this.filename,
    this.url,
  });

  factory StudentDocument.fromJson(Map<String, dynamic> j) {
    return StudentDocument(
      type: (j['type'] as String?) ?? '',
      localPath: j['local_path'] as String?,
      filename: j['filename'] as String?,
      url: j['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'local_path': localPath,
    'filename': filename,
    'url': url,
  };
}

class StudentProfile {
  final int userId;
  final String name;
  final String? school;
  final String? major;
  final List<String> skills;
  final String? availableTime;

  // ✅ 링크
  final String? githubUrl;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? notionUrl;

  // ✅ 문서
  final List<StudentDocument> documents;

  StudentProfile({
    required this.userId,
    required this.name,
    required this.school,
    required this.major,
    required this.skills,
    required this.availableTime,
    required this.githubUrl,
    required this.portfolioUrl,
    required this.linkedinUrl,
    required this.notionUrl,
    required this.documents,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> j) {
    final rawSkills = j['skills'];
    final skills = (rawSkills is List)
        ? rawSkills.map((e) => e.toString()).toList()
        : <String>[];

    final rawDocs = j['documents'];
    final docs = (rawDocs is List)
        ? rawDocs
        .map((e) => StudentDocument.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
        : <StudentDocument>[];

    return StudentProfile(
      userId: (j['user_id'] as num).toInt(),
      name: (j['name'] as String?) ?? '',
      school: j['school'] as String?,
      major: j['major'] as String?,
      skills: skills,
      availableTime: j['available_time'] as String?,

      githubUrl: j['github_url'] as String?,
      portfolioUrl: j['portfolio_url'] as String?,
      linkedinUrl: j['linkedin_url'] as String?,
      notionUrl: j['notion_url'] as String?,

      documents: docs,
    );
  }

  StudentProfile copyWith({
    int? userId,
    String? name,
    String? school,
    String? major,
    List<String>? skills,
    String? availableTime,
    String? githubUrl,
    String? portfolioUrl,
    String? linkedinUrl,
    String? notionUrl,
    List<StudentDocument>? documents,
  }) {
    return StudentProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      school: school ?? this.school,
      major: major ?? this.major,
      skills: skills ?? this.skills,
      availableTime: availableTime ?? this.availableTime,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      notionUrl: notionUrl ?? this.notionUrl,
      documents: documents ?? this.documents,
    );
  }
}
