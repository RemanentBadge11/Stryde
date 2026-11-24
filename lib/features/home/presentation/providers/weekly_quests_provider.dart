import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/core/database/local_cache_service.dart';
import 'package:stryde/core/services/location_timezone_service.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/home/data/completed_quests_repository.dart';
import 'package:stryde/features/home/data/user_quests_repository.dart';
import 'package:stryde/features/home/domain/entities/quest.dart';
import 'package:stryde/features/home/presentation/providers/login_streak_provider.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';

final weeklyQuestsProvider =
    NotifierProvider<WeeklyQuestsNotifier, WeeklyQuestState>(
      WeeklyQuestsNotifier.new,
    );

class WeeklyQuestsNotifier extends Notifier<WeeklyQuestState> {
  String? _activeUserId;

  @override
  WeeklyQuestState build() {
    final user = ref.watch(currentUserProvider);
    final repo = ref.read(userQuestsRepositoryProvider);
    final tzService = ref.read(locationTimezoneServiceProvider);
    _activeUserId = user?.id;

    final initialQuests = repo.generateWeeklyQuests(
      userId: user?.id ?? 'local_user',
      timezone: tzService.getDeviceTimezone(),
    );

    final initial = WeeklyQuestState(
      quests: List<Quest>.unmodifiable(initialQuests.map(Quest.fromUserQuest)),
      endsAt: initialQuests.first.expiresAt.toLocal(),
      isEmptyOffline: false,
    );

    ref.listen(currentUserProvider, (_, nextUser) {
      final nextId = nextUser?.id;
      if (nextId == _activeUserId) return;
      _activeUserId = nextId;
      unawaited(_hydrate(nextId));
    });

    Future.microtask(() => _hydrate(user?.id));

    return initial;
  }

  Future<void> _hydrate(String? userId) async {
    final repo = ref.read(userQuestsRepositoryProvider);
    final tzService = ref.read(locationTimezoneServiceProvider);
    final localCache = ref.read(localCacheServiceProvider);
    final effectiveUserId = userId ?? 'local_user';

    final profile = await localCache.getCachedProfile(effectiveUserId);
    if (!ref.mounted) return;
    final timezone = profile?.timezone ?? tzService.getDeviceTimezone();

    try {
      final userQuests = await repo.getOrGenerateQuests(
        userId: effectiveUserId,
        questType: 'weekly',
        timezone: timezone,
        history: const [],
      );

      if (!ref.mounted || _activeUserId != userId) return;

      if (userQuests.isEmpty) {
        state = WeeklyQuestState(
          quests: const <Quest>[],
          endsAt: tzService
              .nextWeeklySundayMidnight(timezone: timezone)
              .toLocal(),
          isEmptyOffline: true,
        );
        return;
      }

      final quests = userQuests.map(Quest.fromUserQuest).toList();
      final endsAt = userQuests.first.expiresAt.toLocal();

      state = WeeklyQuestState(
        quests: List<Quest>.unmodifiable(quests),
        endsAt: endsAt,
        isEmptyOffline: false,
      );

      final completedRepo = ref.read(completedQuestsRepositoryProvider);
      if (completedRepo != null && userId != null) {
        final records = await completedRepo.fetch(effectiveUserId);
        if (records.isNotEmpty) {
          final completedIds = records
              .where((r) => r.questType == 'quest' || r.questType == 'weekly')
              .where((r) => r.isWithinWindow(const Duration(days: 7)))
              .map((r) => r.questId)
              .toSet();
          if (completedIds.isNotEmpty && ref.mounted) {
            state = WeeklyQuestState(
              quests: List<Quest>.unmodifiable([
                for (final q in state.quests)
                  completedIds.contains(q.id)
                      ? q.copyWith(isCompleted: true)
                      : q,
              ]),
              endsAt: state.endsAt,
              isEmptyOffline: state.isEmptyOffline,
            );
          }
        }
      }
    } catch (_) {
      // Degrades gracefully
    }
  }

  bool complete(String id) {
    refreshIfNeeded();
    final index = state.quests.indexWhere((quest) => quest.id == id);
    if (index == -1 || state.quests[index].isCompleted) return false;

    final quest = state.quests[index];
    final now = DateTime.now();

    state = WeeklyQuestState(
      quests: <Quest>[
        for (var i = 0; i < state.quests.length; i++)
          if (i == index)
            state.quests[i].copyWith(isCompleted: true)
          else
            state.quests[i],
      ],
      endsAt: state.endsAt,
      isEmptyOffline: state.isEmptyOffline,
    );

    final userId = _activeUserId ?? 'local_user';
    final repo = ref.read(userQuestsRepositoryProvider);
    unawaited(
      repo.completeQuest(
        userId: userId,
        questId: id,
        questType: 'weekly',
        completedAt: now,
      ),
    );

    final completedRepo = ref.read(completedQuestsRepositoryProvider);
    if (completedRepo != null && _activeUserId != null) {
      unawaited(
        completedRepo.insert(
          userId: _activeUserId!,
          questId: id,
          questType: 'quest',
          completedAt: now,
        ),
      );
    }

    ref.read(userProgressionProvider.notifier).addXp(quest.xp);
    ref
        .read(xpTransactionsProvider.notifier)
        .log(
          description: 'Quest · ${quest.title}',
          amount: quest.xp,
          source: XpSource.quest,
        );
    ref.read(loginStreakProvider.notifier).recordActivity();
    return true;
  }

  void refresh() {
    unawaited(_hydrate(_activeUserId));
  }

  void refreshIfNeeded({bool force = false}) {
    final now = DateTime.now();
    if (force || !now.isBefore(state.endsAt)) {
      unawaited(_hydrate(_activeUserId));
    }
  }
}
