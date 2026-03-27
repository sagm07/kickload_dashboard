import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/test_run.dart';
import '../theme/app_theme.dart';
import 'create_test.dart';
import 'run_test.dart';
import '../widgets/create_test_button.dart';
import '../widgets/error_rate_donut.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/recent_test_tile.dart';
import '../widgets/response_time_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/system_status_banner.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onCreateTest;
  final String userName;
  final String userEmail;

  const DashboardScreen({
    super.key,
    this.onCreateTest,
    this.userName = 'User',
    this.userEmail = '',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Timer? _liveTimer;
  final _rng = Random();

  // Live metric state
  int _activeTests = 3;
  double _avgResponseMs = 320;
  double _errorRatePct = 2.0;
  int _requestsPerSec = 1400;

  // Trend directions (true = up = bad for error/response, good for requests/active)
  bool _activeTestsUp = true;
  bool _responseUp = true;
  bool _errorUp = false;
  bool _requestsUp = true;

  // Deltas displayed
  int _activeTestsDelta = 1;
  double _responseDelta = 10;
  double _errorDelta = 0.5;
  int _requestsDelta = 120;

  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _isLoading = false);
    });

    // Live ticker — update every 2 seconds
    _liveTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _activeTests = (_activeTests + (_rng.nextBool() ? 1 : -1)).clamp(0, 12);
        _activeTestsDelta = 1 + _rng.nextInt(2);
        _activeTestsUp = _rng.nextBool();

        _avgResponseMs = (_avgResponseMs + (_rng.nextDouble() * 30 - 15))
            .clamp(180.0, 600.0);
        _responseDelta = (5 + _rng.nextDouble() * 20).roundToDouble();
        _responseUp = _rng.nextBool();

        _errorRatePct = (_errorRatePct + (_rng.nextDouble() * 0.4 - 0.2))
            .clamp(0.0, 10.0);
        _errorDelta = (0.1 + _rng.nextDouble() * 0.5)
            .toStringAsFixed(1)
            .let(double.parse);
        _errorUp = _rng.nextBool();

        _requestsPerSec = (_requestsPerSec + (_rng.nextInt(200) - 100))
            .clamp(200, 3000);
        _requestsDelta = 50 + _rng.nextInt(200);
        _requestsUp = _rng.nextBool();
      });
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: _isLoading ? const LoadingSkeleton() : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F6FEB), Color(0xFF58A6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Text(
            'Kickload',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded,
                  color: AppColors.textSecondary, size: 22),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14, left: 2),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.blue.withOpacity(0.2),
            child: Text(
              widget.userName.trim().isNotEmpty
                  ? widget.userName.trim().substring(0, 1).toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: AppColors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 20),
          _buildMetricsGrid(),
          const SizedBox(height: 20),
          CreateTestButton(onPressed: _onCreateTest),
          const SizedBox(height: 24),
          _buildPerformanceSection(),
          const SizedBox(height: 24),
          _buildRecentTests(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back 👋',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formattedDate(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SystemStatusBanner(status: SystemStatus.stable),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'ACTIVE TESTS',
                value: '$_activeTests',
                unit: 'running',
                trendDelta: '+$_activeTestsDelta',
                trendUp: _activeTestsUp,
                icon: Icons.science_outlined,
                accentColor: AppColors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'AVG RESPONSE',
                value: _avgResponseMs.toStringAsFixed(0),
                unit: 'ms',
                trendDelta: '${_responseUp ? '+' : '-'}${_responseDelta.toStringAsFixed(0)}ms',
                trendUp: _responseUp,
                icon: Icons.speed_rounded,
                accentColor: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'ERROR RATE',
                value: _errorRatePct.toStringAsFixed(1),
                unit: '%',
                trendDelta: '${_errorUp ? '+' : '-'}${_errorDelta.toStringAsFixed(1)}%',
                trendUp: _errorUp,
                icon: Icons.error_outline_rounded,
                accentColor: AppColors.danger,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'REQUESTS/SEC',
                value: _requestsPerSec >= 1000
                    ? '${(_requestsPerSec / 1000).toStringAsFixed(1)}k'
                    : '$_requestsPerSec',
                unit: 'req/s',
                trendDelta: '${_requestsUp ? '+' : '-'}$_requestsDelta',
                trendUp: !_requestsUp, // more requests = good, trendUp=false means green
                icon: Icons.swap_vert_rounded,
                accentColor: AppColors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📈  Performance Metrics',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const ResponseTimeChart(),
        const SizedBox(height: 12),
        const ErrorRateDonut(),
      ],
    );
  }

  Widget _buildRecentTests() {
    final tests = TestRun.dummyData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Tests',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        tests.isEmpty
            ? const EmptyTestsState()
            : Column(
                children: tests
                    .map((t) => RecentTestTile(run: t))
                    .toList(),
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _onCreateTest() {
    final goToCreate = widget.onCreateTest;
    if (goToCreate != null) {
      goToCreate();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        content: const Row(
          children: [
            Icon(Icons.rocket_launch_rounded, color: AppColors.blue, size: 18),
            SizedBox(width: 10),
            Text('Test configurator coming soon!',
                style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month]} ${now.day}, ${now.year}';
  }
}

class DashboardPage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const DashboardPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _openCreateTest() => setState(() => _selectedIndex = 1);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
        onCreateTest: _openCreateTest,
      ),
      const CreateTestScreen(),
      const RunTestScreen(),
      _ProfileScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.blue,
          unselectedItemColor: AppColors.textMuted,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create_outlined),
              activeIcon: Icon(Icons.create_rounded),
              label: 'Create Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline_rounded),
              activeIcon: Icon(Icons.play_circle_rounded),
              label: 'Run Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _ProfileScreen({
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.blue.withOpacity(0.15),
              child: Text(
                userName.trim().isNotEmpty
                    ? userName.trim().substring(0, 1).toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName.isEmpty ? 'User' : userName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Profile tools are coming soon.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dart extension helper
extension _LetExt<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
