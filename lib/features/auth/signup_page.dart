import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import 'auth_model.dart';
import 'role_select_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _identifierController = TextEditingController(); // email or phone
  final _passwordController = TextEditingController();

  UserRole? _role;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String value) => value.trim().contains('@');

  Future<void> _pickRole() async {
    final selected = await Navigator.push<UserRole>(
      context,
      MaterialPageRoute(
        builder: (_) => RoleSelectPage(
          onSelect: (role) => Navigator.pop(context, role),
        ),
      ),
    );
    if (selected != null) setState(() => _role = selected);
  }

  Future<void> _onSignup() async {
    final scope = AppScope.of(context);

    final id = _identifierController.text.trim();
    final pw = _passwordController.text.trim();
    final role = _role;

    if (id.isEmpty || pw.isEmpty || role == null) {
      UiUtils.snack(context, 'Please enter email/phone, password, and role.');
      return;
    }

    final email = _looksLikeEmail(id) ? id : null;
    final phone = _looksLikeEmail(id) ? null : id;

    setState(() => _isLoading = true);
    try {
      // Server behavior: signup returns user, NOT token.
      // We do: signup -> login -> me inside AuthController.signupThenLogin()
      await scope.auth.signupThenLogin(
        email: email,
        phone: phone,
        password: pw,
        role: role,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
            (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, _prettyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _prettyError(Object e) {
    final msg = e.toString();
    return msg.replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create Account',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Labeled(
            label: 'Email or Phone',
            child: TextField(
              controller: _identifierController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'user@example.com or 01012345678',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Labeled(
            label: 'Password',
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _isLoading ? null : _onSignup(),
              decoration: const InputDecoration(
                hintText: 'Minimum 6 characters (server policy)',
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: _role == null ? 'Select Role' : 'Role: ${_role!.name}',
            onPressed: _isLoading ? null : _pickRole,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: _isLoading ? 'Creating account...' : 'Sign Up',
            onPressed: _isLoading ? null : _onSignup,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }
}
