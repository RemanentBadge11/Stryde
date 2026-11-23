import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stryde/features/medals/domain/entities/medal.dart';
import 'package:stryde/features/progression/domain/entities/rank.dart';

sealed class ProgressionNotification {
  const ProgressionNotification();
  String get id;
}

class LevelUpNotification extends ProgressionNotification {
  const LevelUpNotification({required this.oldLevel, required this.newLevel});

  final int oldLevel;
  final int newLevel;

  @override
  String get id => 'level_${oldLevel}_$newLevel';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelUpNotification &&
          runtimeType == other.runtimeType &&
          oldLevel == other.oldLevel &&
          newLevel == other.newLevel;

  @override
  int get hashCode => Object.hash(oldLevel, newLevel);
}

class RankUpNotification extends ProgressionNotification {
  const RankUpNotification({required this.rank});

  final Rank rank;

  @override
  String get id => 'rank_${rank.name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankUpNotification &&
          runtimeType == other.runtimeType &&
          rank.name == other.rank.name;

  @override
  int get hashCode => rank.name.hashCode;
}

class MedalAwardedNotification extends ProgressionNotification {
  const MedalAwardedNotification({required this.medal});

  final Medal medal;

  @override
  String get id => 'medal_${medal.id}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedalAwardedNotification &&
          runtimeType == other.runtimeType &&
          medal.id == other.medal.id;

  @override
  int get hashCode => medal.id.hashCode;
}

List<ProgressionNotification> calculateProgressionNotifications({
  required int fromLevel,
  required int toLevel,
}) {
  final notifications = <ProgressionNotification>[];
  if (toLevel <= fromLevel) return notifications;

  for (var lvl = fromLevel; lvl < toLevel; lvl++) {
    final nextLvl = lvl + 1;
    notifications.add(LevelUpNotification(oldLevel: lvl, newLevel: nextLvl));
    if (Ranks.breakthroughLevels.contains(nextLvl)) {
      notifications.add(RankUpNotification(rank: Ranks.forLevel(nextLvl)));
    }
  }
  return notifications;
}

class GlobalNotificationQueue {
  const GlobalNotificationQueue({
    this.currentNotification,
    this.queue = const <ProgressionNotification>[],
    this.isVisible = false,
  });

  final ProgressionNotification? currentNotification;
  final List<ProgressionNotification> queue;
  final bool isVisible;

  Medal? get currentMedal {
    final cur = currentNotification;
    return cur is MedalAwardedNotification ? cur.medal : null;
  }

  GlobalNotificationQueue copyWith({
    ProgressionNotification? currentNotification,
    bool clearCurrentNotification = false,
    List<ProgressionNotification>? queue,
    bool? isVisible,
  }) {
    return GlobalNotificationQueue(
      currentNotification: clearCurrentNotification
          ? null
          : (currentNotification ?? this.currentNotification),
      queue: queue ?? this.queue,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

final globalNotificationProvider =
    NotifierProvider<GlobalNotificationNotifier, GlobalNotificationQueue>(
      GlobalNotificationNotifier.new,
    );

typedef MedalNotificationQueue = GlobalNotificationQueue;
typedef MedalNotificationNotifier = GlobalNotificationNotifier;
final medalNotificationProvider = globalNotificationProvider;

class GlobalNotificationNotifier extends Notifier<GlobalNotificationQueue> {
  Timer? _displayTimer;
  Timer? _transitionTimer;

  @override
  GlobalNotificationQueue build() {
    ref.onDispose(() {
      _displayTimer?.cancel();
      _transitionTimer?.cancel();
    });
    return const GlobalNotificationQueue();
  }

  /// Enqueue notifications (accepts ProgressionNotification or Medal) sequentially.
  void enqueue(List<dynamic> items) {
    if (items.isEmpty) return;

    final notifications = <ProgressionNotification>[];
    for (final item in items) {
      if (item is ProgressionNotification) {
        notifications.add(item);
      } else if (item is Medal) {
        notifications.add(MedalAwardedNotification(medal: item));
      }
    }

    if (notifications.isEmpty) return;

    // Filter duplicates already in queue, currently displayed, or within items
    final newItems = <ProgressionNotification>[];
    for (final n in notifications) {
      if (state.currentNotification?.id == n.id) continue;
      if (state.queue.any((queued) => queued.id == n.id)) continue;
      if (newItems.any((queued) => queued.id == n.id)) continue;
      newItems.add(n);
    }

    if (newItems.isEmpty) return;

    final updatedQueue = List<ProgressionNotification>.from(state.queue)
      ..addAll(newItems);
    state = state.copyWith(queue: updatedQueue);

    if (state.currentNotification == null) {
      _showNext();
    }
  }

  void enqueueMedals(List<Medal> medals) {
    enqueue(medals.map((m) => MedalAwardedNotification(medal: m)).toList());
  }

  void enqueueLevelUp({required int oldLevel, required int newLevel}) {
    enqueue([LevelUpNotification(oldLevel: oldLevel, newLevel: newLevel)]);
  }

  void enqueueRankUp(Rank rank) {
    enqueue([RankUpNotification(rank: rank)]);
  }

  void _showNext() {
    _displayTimer?.cancel();
    _transitionTimer?.cancel();

    if (state.queue.isEmpty) {
      state = state.copyWith(clearCurrentNotification: true, isVisible: false);
      return;
    }

    final nextQueue = List<ProgressionNotification>.from(state.queue);
    final nextItem = nextQueue.removeAt(0);

    state = GlobalNotificationQueue(
      currentNotification: nextItem,
      queue: nextQueue,
      isVisible: true,
    );

    // Keep visible for 3.5 seconds
    _displayTimer = Timer(const Duration(milliseconds: 3500), () {
      dismissCurrent();
    });
  }

  void dismissCurrent() {
    _displayTimer?.cancel();
    if (!state.isVisible && state.currentNotification == null) return;

    state = state.copyWith(isVisible: false);

    _transitionTimer = Timer(const Duration(milliseconds: 350), () {
      if (state.queue.isNotEmpty) {
        _showNext();
      } else {
        state = state.copyWith(clearCurrentNotification: true);
      }
    });
  }
}
