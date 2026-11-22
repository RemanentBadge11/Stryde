import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/providers/loading_flag_notifier.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/progression/data/xp_history_repository.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';

final xpTransactionsProvider =
    NotifierProvider<XpTransactionsNotifier, List<XpTransaction>>(
      XpTransactionsNotifier.new,
    );

final xpTransactionsLoadingProvider =
    NotifierProvider<LoadingFlagNotifier, bool>(LoadingFlagNotifier.new);

class XpTransactionsNotifier extends Notifier<List<XpTransaction>> {
  var _sequence = 0;
  String? _activeUserId;
  String? _loadingUserId;
  bool _hydrated = false;
  final List<XpTransaction> _pending = <XpTransaction>[];

  XpHistoryRepository? get _repository => ref.read(xpHistoryRepositoryProvider);

  @override
  List<XpTransaction> build() {
    final user = ref.read(currentUserProvider);
    _activeUserId = user?.id;
    if (user != null && _repository != null) {
      ref.read(xpTransactionsLoadingProvider.notifier).setLoading(true);
      unawaited(_fetch(user.id));
    }
    ref.listen(currentUserProvider, (_, user) => _handleUserChanged(user));
    return const <XpTransaction>[];
  }

  void _handleUserChanged(User? user) {
    final userId = user?.id;
    if (userId == _activeUserId) return;
    _activeUserId = userId;
    _loadingUserId = null;
    _hydrated = false;
    _pending.clear();
    state = const <XpTransaction>[];

    final loading = userId != null && _repository != null;
    ref.read(xpTransactionsLoadingProvider.notifier).setLoading(loading);
    if (loading) unawaited(_fetch(userId));
  }

  Future<void> _fetch(String userId) async {
    if (_activeUserId != userId || _hydrated || _loadingUserId == userId) {
      return;
    }
    final repository = _repository;
    if (repository == null) return;
    _loadingUserId = userId;

    try {
      final remote = await repository.fetch(userId);
      if (_activeUserId != userId) return;
      final pending = List<XpTransaction>.of(_pending);
      state = _merge(pending, remote);
      _pending.clear();
      _hydrated = true;
      for (final transaction in pending) {
        unawaited(_insert(userId, transaction));
      }
    } catch (_) {
      if (_activeUserId == userId) {
        final pending = List<XpTransaction>.of(_pending);
        _pending.clear();
        _hydrated = true;
        for (final transaction in pending) {
          unawaited(_insert(userId, transaction));
        }
      }
    } finally {
      if (_loadingUserId == userId) _loadingUserId = null;
      if (_activeUserId == userId) {
        ref.read(xpTransactionsLoadingProvider.notifier).setLoading(false);
      }
    }
  }

  void log({
    required String description,
    required int amount,
    required XpSource source,
    DateTime? occurredAt,
  }) {
    if (amount <= 0) return;
    final now = occurredAt ?? DateTime.now();
    final transaction = XpTransaction(
      id: '${now.microsecondsSinceEpoch}-${_sequence++}',
      description: description,
      amount: amount,
      occurredAt: now,
      source: source,
    );
    state = <XpTransaction>[transaction, ...state].take(100).toList();

    final userId = _activeUserId;
    if (userId == null || _repository == null) return;
    if (!_hydrated) {
      _pending.add(transaction);
      return;
    }
    unawaited(_insert(userId, transaction));
  }

  Future<void> _insert(String userId, XpTransaction transaction) async {
    final repository = _repository;
    if (repository == null) return;
    try {
      final persisted = await repository.insert(
        userId: userId,
        transaction: transaction,
      );
      if (_activeUserId != userId) return;
      state = <XpTransaction>[
        for (final item in state)
          if (item.id == transaction.id) persisted else item,
      ];
    } catch (_) {
      // Keep the optimistic ledger row while offline.
    }
  }

  List<XpTransaction> _merge(
    List<XpTransaction> pending,
    List<XpTransaction> remote,
  ) {
    final seen = <String>{};
    final merged = <XpTransaction>[
      ...pending,
      ...remote,
    ].where((item) => seen.add(item.id)).toList();
    merged.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return merged.take(100).toList(growable: false);
  }
}
