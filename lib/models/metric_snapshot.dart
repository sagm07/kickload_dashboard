class MetricSnapshot {
  final int activeTests;
  final double avgResponseMs;
  final double errorRatePct;
  final int requestsPerSec;

  // Trend deltas (positive = going up, negative = going down)
  final int activeTestsDelta;
  final double avgResponseMsDelta;
  final double errorRateDelta;
  final int requestsDelta;

  const MetricSnapshot({
    required this.activeTests,
    required this.avgResponseMs,
    required this.errorRatePct,
    required this.requestsPerSec,
    required this.activeTestsDelta,
    required this.avgResponseMsDelta,
    required this.errorRateDelta,
    required this.requestsDelta,
  });

  static const initial = MetricSnapshot(
    activeTests: 3,
    avgResponseMs: 320,
    errorRatePct: 2.0,
    requestsPerSec: 1400,
    activeTestsDelta: 1,
    avgResponseMsDelta: 10,
    errorRateDelta: -0.5,
    requestsDelta: 120,
  );
}
