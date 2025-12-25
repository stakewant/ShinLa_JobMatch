enum JobStatus { OPEN, CLOSED }

JobStatus jobStatusFromString(String v) {
  return JobStatus.values.firstWhere(
        (e) => e.name == v,
    orElse: () => JobStatus.OPEN,
  );
}

class JobImageOut {
  final int id;
  final int jobPostId;
  final String imageUrl;

  JobImageOut({
    required this.id,
    required this.jobPostId,
    required this.imageUrl,
  });

  factory JobImageOut.fromJson(Map<String, dynamic> j) {
    return JobImageOut(
      id: (j['id'] as num).toInt(),
      jobPostId: (j['job_post_id'] as num).toInt(),
      imageUrl: (j['image_url'] as String?) ?? '',
    );
  }
}

class JobPostOut {
  final int id;
  final int companyId;
  final String title;
  final int? wage;
  final String description;
  final String region;
  final JobStatus status;
  final bool isDeleted;
  final List<JobImageOut> images;

  JobPostOut({
    required this.id,
    required this.companyId,
    required this.title,
    required this.wage,
    required this.description,
    required this.region,
    required this.status,
    required this.isDeleted,
    required this.images,
  });

  factory JobPostOut.fromJson(Map<String, dynamic> j) {
    final imgs = (j['images'] as List? ?? [])
        .map((e) => JobImageOut.fromJson(e as Map<String, dynamic>))
        .toList();

    return JobPostOut(
      id: (j['id'] as num).toInt(),
      companyId: (j['company_id'] as num).toInt(),
      title: (j['title'] as String?) ?? '',
      wage: (j['wage'] as num?)?.toInt(),
      description: (j['description'] as String?) ?? '',
      region: (j['region'] as String?) ?? '',
      status: jobStatusFromString((j['status'] as String?) ?? 'OPEN'),
      isDeleted: (j['is_deleted'] as bool?) ?? false,
      images: imgs,
    );
  }
}
