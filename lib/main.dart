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

import 'features/applications/application_api.dart';
import 'features/applications/application_controller.dart';
import 'features/applications/company_requests_page.dart';
import 'features/applications/student_requests_page.dart';

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
  late final ApplicationController _applications;

  bool _ready = false;

  @override
  void initState() {
    super.initState();

    _client = DioClient();

    _auth = AuthController(_client);
    _jobs = JobController(JobApi(_client));
    _chat = ChatController(ChatApi(_client));
    _profile = ProfileController(ProfileApi(_client));
    _applications = ApplicationController(ApplicationApi(_client));

    _boot();
  }

  Future<void> _boot() async {
    await _auth.loadSession();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AppScope(
      auth: _auth,
      jobs: _jobs,
      chat: _chat,
      profile: _profile,
      applications: _applications,
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
  final ApplicationController applications;

  const AppScope({
    super.key,
    required this.auth,
    required this.jobs,
    required this.chat,
    required this.profile,
    required this.applications,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final AppScope? result =
    context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(result != null, 'No AppScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) {
    return auth != oldWidget.auth ||
        jobs != oldWidget.jobs ||
        chat != oldWidget.chat ||
        profile != oldWidget.profile ||
        applications != oldWidget.applications;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _booted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_booted) return;
    _booted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final scope = AppScope.of(context);
      final me = scope.auth.me;

      // 채팅방 목록 1회 갱신
      try {
        await scope.chat.refreshRooms();
      } catch (_) {}

      // 요청 뱃지 갱신 (JWT 기준)
      if (me != null) {
        try {
          if (me.role.name == 'COMPANY') {
            await scope.applications.refreshIncoming();
          } else if (me.role.name == 'STUDENT') {
            await scope.applications.refreshOutgoing();
          }
        } catch (_) {}
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    final scope = AppScope.of(context);

    await scope.auth.logout();
    scope.profile.clear();
    await scope.chat.disposeAllSockets();
    scope.chat.clearUnreadAll();

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

    final apps = scope.applications;
    final chat = scope.chat;

    final isCompany = me != null && me.role.name == 'COMPANY';
    final isStudent = me != null && me.role.name == 'STUDENT';

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
        child: AnimatedBuilder(
          animation: Listenable.merge([apps, chat]),
          builder: (context, _) {
            final requestBadge = isCompany
                ? apps.pendingIncomingCount
                : isStudent
                ? apps.pendingOutgoingCount
                : 0;

            final chatBadge = chat.totalUnread;

            return Column(
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
                  child: _BadgeText(text: 'Chats', count: chatBadge),
                ),
                const SizedBox(height: 10),

                if (isCompany) ...[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompanyRequestsPage(),
                        ),
                      );
                    },
                    child: _BadgeText(
                      text: 'Requests (Company)',
                      count: requestBadge,
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else if (isStudent) ...[
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentRequestsPage(),
                        ),
                      );
                    },
                    child: _BadgeText(
                      text: 'My Requests (Student)',
                      count: requestBadge,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfilePage(),
                      ),
                    );
                  },
                  child: const Text('Profile'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BadgeText extends StatelessWidget {
  final String text;
  final int count;

  const _BadgeText({
    required this.text,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Align(alignment: Alignment.center, child: Text(text)),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: _Badge(count: count),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count >= 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
