import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/home/domain/entities/habit.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';

final habitsProvider = NotifierProvider<HabitsNotifier, HabitState>(
  HabitsNotifier.new,
);

class HabitsNotifier extends Notifier<HabitState> {
  static const Duration cycle = Duration(hours: 12);

  @override
  HabitState build() {
    return HabitState(
      completedIds: const <String>{},
      endsAt: DateTime.now().add(cycle),
    );
  }

  bool complete(String id, {required int xp, required String title}) {
    refreshIfNeeded();
    if (state.completedIds.contains(id)) return false;

    state = HabitState(
      completedIds: <String>{...state.completedIds, id},
      endsAt: state.endsAt,
    );
    ref.read(userProgressionProvider.notifier).addXp(xp);
    ref
        .read(xpTransactionsProvider.notifier)
        .log(description: 'Habit · $title', amount: xp, source: XpSource.habit);
    ref.read(loginStreakProvider.notifier).recordActivity();
    return true;
  }

  void refreshIfNeeded() {
    if (!DateTime.now().isBefore(state.endsAt)) {
      state = HabitState(
        completedIds: const <String>{},
        endsAt: DateTime.now().add(cycle),
      );
    }
  }
}
