import 'package:flutter/foundation.dart';
import 'job_api.dart';
import 'job_model.dart';

class JobController extends ChangeNotifier {
  final JobApi _api;
  JobController(this._api);

  List<JobPostOut> _items = [];
  List<JobPostOut> get items => _items;

  Future<void> refresh({String? region, JobStatus? status}) async {
    _items = await _api.list(region: region, status: status);
    notifyListeners();
  }

  Future<JobPostOut> detail(int id) => _api.detail(id);

  Future<JobPostOut> register({
    required String title,
    required int? wage,
    required String description,
    required String region,
    required JobStatus status,
  }) async {
    final created = await _api.create(
      title: title,
      wage: wage,
      description: description,
      region: region,
      status: status,
    );
    await refresh();
    return created;
  }

  Future<JobPostOut> edit(
      int id, {
        required String title,
        required int? wage,
        required String description,
        required String region,
        required JobStatus status,
      }) async {
    final updated = await _api.update(
      id,
      title: title,
      wage: wage,
      description: description,
      region: region,
      status: status,
    );
    await refresh();
    return updated;
  }

  Future<JobImageOut> addImage(int jobPostId, String imageUrl) async {
    final img = await _api.addImage(jobPostId, imageUrl);
    await refresh();
    return img;
  }
}
