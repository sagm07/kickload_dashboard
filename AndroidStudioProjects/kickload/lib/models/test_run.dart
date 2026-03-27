enum TestStatus { completed, running, failed }

class TestRun {
  final String id;
  final String name;
  final String endpoint;
  final TestStatus status;
  final DateTime timestamp;
  final int durationMs;
  final double errorRate;
  final int requestsPerSec;

  const TestRun({
    required this.id,
    required this.name,
    required this.endpoint,
    required this.status,
    required this.timestamp,
    required this.durationMs,
    required this.errorRate,
    required this.requestsPerSec,
  });

  static final List<TestRun> dummyData = [
    TestRun(
      id: 'T-001',
      name: 'Auth Stress Test',
      endpoint: '/api/v1/auth/login',
      status: TestStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      durationMs: 320,
      errorRate: 0.8,
      requestsPerSec: 1200,
    ),
    TestRun(
      id: 'T-002',
      name: 'Upload Spike Test',
      endpoint: '/api/v2/upload/chunk',
      status: TestStatus.running,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      durationMs: 870,
      errorRate: 2.3,
      requestsPerSec: 450,
    ),
    TestRun(
      id: 'T-003',
      name: 'Search Load Test',
      endpoint: '/api/v1/search',
      status: TestStatus.failed,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      durationMs: 5200,
      errorRate: 18.4,
      requestsPerSec: 800,
    ),
    TestRun(
      id: 'T-004',
      name: 'Dashboard Soak Test',
      endpoint: '/api/v1/dashboard',
      status: TestStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      durationMs: 290,
      errorRate: 0.1,
      requestsPerSec: 2000,
    ),
    TestRun(
      id: 'T-005',
      name: 'Webhook Endurance',
      endpoint: '/webhooks/events',
      status: TestStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      durationMs: 410,
      errorRate: 1.2,
      requestsPerSec: 600,
    ),
  ];
}
