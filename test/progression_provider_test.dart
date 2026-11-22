import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stryde/features/home/presentation/providers/habits_provider.dart';
import 'package:stryde/features/progression/domain/entities/xp_transaction.dart';
import 'package:stryde/features/progression/presentation/providers/skill_allocations_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';
import 'package:stryde/features/progression/presentation/providers/xp_transactions_provider.dart';

void main() {
  test('starts at level 1 with no XP and no skill points', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final progression = container.read(userProgressionProvider);
    expect(progression.currentLevel, 1);
    expect(progression.currentXp, 0);
    expect(progression.skillPoints, 0);
    expect(progression.rankTitle, 'Fresher');
    expect(progression.xpToNextLevel, 500);
  });

  test('every 500 XP crosses one level and grants one skill point', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(userProgressionProvider.notifier);
    notifier.addXp(500);

    var progression = container.read(userProgressionProvider);
    expect(progression.currentLevel, 2);
    expect(progression.currentXp, 0);
    expect(progression.skillPoints, 1);

    notifier.addXp(250);
    progression = container.read(userProgressionProvider);
    expect(progression.currentLevel, 2);
    expect(progression.currentXp, 250);
    expect(progression.progress, 0.5);
  });

  test('crossing a rank threshold grants 3 bonus skill points', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(userProgressionProvider.notifier).addXp(500 * 5);

    final progression = container.read(userProgressionProvider);
    expect(progression.currentLevel, 6);
    expect(progression.currentXp, 0);
    expect(progression.rankTitle, 'Rising Star');
    expect(progression.skillPoints, 8);
  });

  test('skill points are spent once and allocated to a muscle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(userProgressionProvider.notifier).addXp(500);
    final allocations = container.read(skillAllocationsProvider.notifier);

    expect(allocations.spend('Chest'), isTrue);
    expect(container.read(skillAllocationsProvider)['Chest'], 1);
    expect(container.read(userProgressionProvider).skillPoints, 0);
    expect(allocations.spend('Back'), isFalse);
  });

  test('habit completion awards XP once and writes a ledger entry', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final habits = container.read(habitsProvider.notifier);
    expect(habits.complete('gym', xp: 50, title: 'Go to the gym'), isTrue);
    expect(habits.complete('gym', xp: 50, title: 'Go to the gym'), isFalse);

    expect(container.read(userProgressionProvider).currentXp, 50);
    final ledger = container.read(xpTransactionsProvider);
    expect(ledger, hasLength(1));
    expect(ledger.first.amount, 50);
    expect(ledger.first.source, XpSource.habit);
    expect(ledger.first.description, contains('Go to the gym'));
  });

  test('level 999 is the hard cap', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(userProgressionProvider.notifier);
    notifier.addXp(500 * 998);
    expect(container.read(userProgressionProvider).currentLevel, 999);

    notifier.addXp(5000);
    expect(container.read(userProgressionProvider).currentLevel, 999);
  });
}
