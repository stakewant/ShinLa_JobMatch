import 'package:flutter/material.dart';

import '../../core/common/widgets.dart';
import '../auth/auth_model.dart';
import 'profile_model.dart';

class UserProfilePage extends StatelessWidget {
  final UserOut user;
  final StudentProfile? studentProfile;

  const UserProfilePage({
    super.key,
    required this.user,
    this.studentProfile,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'User Profile',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: ${user.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Role: ${user.role.name}'),
                  Text('Email: ${user.email ?? "-"}'),
                  Text('Phone: ${user.phone ?? "-"}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (user.role == UserRole.STUDENT) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: studentProfile == null
                    ? const Text('Student profile not loaded.')
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Student Profile', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Name: ${studentProfile!.name}'),
                    Text('School: ${studentProfile!.school ?? "-"}'),
                    Text('Major: ${studentProfile!.major ?? "-"}'),
                    Text('Available: ${studentProfile!.availableTime ?? "-"}'),
                    const SizedBox(height: 8),
                    const Text('Skills', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      studentProfile!.skills.isEmpty
                          ? '-'
                          : studentProfile!.skills.join(', '),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
