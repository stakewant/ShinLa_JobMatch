import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController(); // email or phone
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String value) => value.trim().contains('@');

  Future<void> _onLogin() async {
    final scope = AppScope.of(context);

    final id = _identifierController.text.trim();
    final pw = _passwordController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      UiUtils.snack(context, 'Please enter email/phone and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_looksLikeEmail(id)) {
        await scope.auth.loginWithEmail(email: id, password: pw);
      } else {
        await scope.auth.loginWithPhone(phone: id, password: pw);
      }

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
      title: 'Sign In',
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
              onSubmitted: (_) => _isLoading ? null : _onLogin(),
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: _isLoading ? 'Signing in...' : 'Sign In',
            onPressed: _isLoading ? null : _onLogin,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupPage()),
              );
            },
            child: const Text('Create an account'),
          ),
        ],
      ),
    );
  }
}
