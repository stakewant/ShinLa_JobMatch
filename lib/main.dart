import 'package:flutter/material.dart';

import 'core/api/dio_client.dart';
import 'core/common/theme.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/login_page.dart';

import 'features/job/job_api.dart';
import 'features/job/job_controller.dart';
import 'features/job/job_list_page.dart';

import 'features/chat/chat_api.dart';
import 'features/chat/chat_controller.dart';
import 'features/chat/chat_list_page.dart';

import 'features/profile/profile_api.dart';
import 'features/profile/profile_controller.dart';
import 'features/profile/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DioClient _client;

  late final AuthController _auth;
  late final JobController _jobs;
  late final ChatController _chat;
  late final ProfileController _profile;

  bool _ready = false;

  @override
  void initState() {
    super.initState();

    _client = DioClient();

    _auth = AuthController(_client);
    _jobs = JobController(JobApi(_client));
    _chat = ChatController(ChatApi(_client));
    _profile = ProfileController(ProfileApi(_client));

    _boot();
  }

  Future<void> _boot() async {
    await _auth.loadSession(); // token + /users/me
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return AppScope(
      auth: _auth,
      jobs: _jobs,
      chat: _chat,
      profile: _profile,
      child: MaterialApp(
        title: 'ShinLa JobMatch',
        theme: AppTheme.light(),
        home: _auth.isAuthed ? const HomePage() : const LoginPage(),
      ),
    );
  }
}

class AppScope extends InheritedWidget {
  final AuthController auth;
  final JobController jobs;
  final ChatController chat;
  final ProfileController profile;

  const AppScope({
    super.key,
    required this.auth,
    required this.jobs,
    required this.chat,
    required this.profile,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final AppScope? result = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(result != null, 'No AppScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) {
    return auth != oldWidget.auth ||
        jobs != oldWidget.jobs ||
        chat != oldWidget.chat ||
        profile != oldWidget.profile;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final scope = AppScope.of(context);
    await scope.auth.logout();
    scope.profile.clear();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final me = scope.auth.me;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (me == null)
              const Text('No user loaded.')
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Signed in as:\n'
                        'id: ${me.id}\n'
                        'role: ${me.role.name}\n'
                        'email: ${me.email}\n'
                        'phone: ${me.phone}',
                  ),
                ),
              ),
            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JobListPage()),
                );
              },
              child: const Text('Jobs'),
            ),
            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListPage()),
                );
              },
              child: const Text('Chats'),
            ),
            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: const Text('Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
