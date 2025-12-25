import 'package:flutter/material.dart';

import '../../core/common/widgets.dart';
import 'auth_model.dart';

class RoleSelectPage extends StatelessWidget {
  final void Function(UserRole role) onSelect;

  const RoleSelectPage({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select Role',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose your account type.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Student (STUDENT)',
            onPressed: () => onSelect(UserRole.STUDENT),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Company (COMPANY)',
            onPressed: () => onSelect(UserRole.COMPANY),
          ),
        ],
      ),
    );
  }
}
