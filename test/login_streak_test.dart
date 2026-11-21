import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';

void main() {
  test('streak counts once daily, continues, and resets after a miss', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(loginStreakProvider.notifier);

    expect(notifier.recordActivity(DateTime(2030, 1, 1)), isTrue);
    expect(notifier.recordActivity(DateTime(2030, 1, 1, 20)), isFalse);
    expect(container.read(loginStreakProvider).streak, 1);

    expect(notifier.recordActivity(DateTime(2030, 1, 2)), isTrue);
    expect(container.read(loginStreakProvider).streak, 2);

    notifier.refreshIfNeeded(DateTime(2030, 1, 4));
    expect(container.read(loginStreakProvider).streak, 0);

    expect(notifier.recordActivity(DateTime(2030, 1, 4)), isTrue);
    expect(container.read(loginStreakProvider).streak, 1);
  });
}
