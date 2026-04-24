import 'package:flutter_test/flutter_test.dart';

extension IntegrationWaits on WidgetTester {
  Future<void> waitUntilVisible(
    Finder finder, {
    Duration timeout = const Duration(seconds: 12),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final end = binding.clock.fromNowBy(timeout);

    while (binding.clock.now().isBefore(end)) {
      await pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    throw TestFailure('Timed out waiting for $finder');
  }

  Future<void> waitUntilAbsent(
    Finder finder, {
    Duration timeout = const Duration(seconds: 12),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final end = binding.clock.fromNowBy(timeout);

    while (binding.clock.now().isBefore(end)) {
      await pump(step);
      if (finder.evaluate().isEmpty) {
        return;
      }
    }

    throw TestFailure('Timed out waiting for $finder to disappear');
  }

  Future<void> tapWhenVisible(
    Finder finder, {
    Duration timeout = const Duration(seconds: 12),
  }) async {
    await waitUntilVisible(finder, timeout: timeout);
    await ensureVisible(finder);
    await tap(finder);
    await pump();
  }
}
