import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('CachedProfileEntry')
class CachedProfiles extends Table {
  @override
  String get tableName => 'cached_profile';

  TextColumn get id => text()(); // user id
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  IntColumn get skillPoints => integer().withDefault(const Constant(0))();
  IntColumn get totalXp => integer().withDefault(const Constant(0))();
  IntColumn get availableSkillPoints =>
      integer().withDefault(const Constant(0))();
  TextColumn get username => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get lastActivityOn => dateTime().nullable()();
  IntColumn get goalSteps => integer().nullable()();
  RealColumn get goalWater => real().nullable()();
  IntColumn get goalProtein => integer().nullable()();
  TextColumn get themeMode => text().nullable()();
  TextColumn get accentColor => text().nullable()();
  TextColumn get timezone => text().nullable()();
  DateTimeColumn get lastUpdated =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncQueueEntry')
class SyncQueue extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType =>
      text()(); // 'profile', 'workout', 'medal', 'skill'
  TextColumn get action => text()(); // 'update', 'insert', 'create_profile'
  TextColumn get payload => text()(); // JSON string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('CachedMedalEntry')
class CachedMedals extends Table {
  @override
  String get tableName => 'cached_medals';

  TextColumn get userId => text()();
  TextColumn get medalId => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId, medalId};
}

@DataClassName('CachedSkillEntry')
class CachedSkills extends Table {
  @override
  String get tableName => 'cached_skills';

  TextColumn get userId => text()();
  TextColumn get muscleGroup => text()();
  IntColumn get points => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {userId, muscleGroup};
}

@DataClassName('CachedWorkoutEntry')
class CachedWorkouts extends Table {
  @override
  String get tableName => 'cached_workouts';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get routineName => text()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get durationSeconds => integer()();
  RealColumn get totalVolumeKg => real()();
  TextColumn get rawPayload => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedQuestEntry')
class CachedQuests extends Table {
  @override
  String get tableName => 'cached_quests';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get questType => text()(); // 'daily' or 'weekly'
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get xpReward => integer()();
  TextColumn get targetMetric => text().nullable()();
  RealColumn get targetValue => real().nullable()();
  TextColumn get exerciseName => text().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

QueryExecutor _defaultExecutor() {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return NativeDatabase.memory();
  }
  return driftDatabase(name: 'stryde_local');
}

@DriftDatabase(
  tables: [
    CachedProfiles,
    SyncQueue,
    CachedMedals,
    CachedSkills,
    CachedWorkouts,
    CachedQuests,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _defaultExecutor()) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  @override
  int get schemaVersion => 1;
}
