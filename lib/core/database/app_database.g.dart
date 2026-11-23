// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedProfilesTable extends CachedProfiles
    with TableInfo<$CachedProfilesTable, CachedProfileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skillPointsMeta = const VerificationMeta(
    'skillPoints',
  );
  @override
  late final GeneratedColumn<int> skillPoints = GeneratedColumn<int>(
    'skill_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalXpMeta = const VerificationMeta(
    'totalXp',
  );
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
    'total_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _availableSkillPointsMeta =
      const VerificationMeta('availableSkillPoints');
  @override
  late final GeneratedColumn<int> availableSkillPoints = GeneratedColumn<int>(
    'available_skill_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastActivityOnMeta = const VerificationMeta(
    'lastActivityOn',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivityOn =
      GeneratedColumn<DateTime>(
        'last_activity_on',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _goalStepsMeta = const VerificationMeta(
    'goalSteps',
  );
  @override
  late final GeneratedColumn<int> goalSteps = GeneratedColumn<int>(
    'goal_steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalWaterMeta = const VerificationMeta(
    'goalWater',
  );
  @override
  late final GeneratedColumn<double> goalWater = GeneratedColumn<double>(
    'goal_water',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalProteinMeta = const VerificationMeta(
    'goalProtein',
  );
  @override
  late final GeneratedColumn<int> goalProtein = GeneratedColumn<int>(
    'goal_protein',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accentColorMeta = const VerificationMeta(
    'accentColor',
  );
  @override
  late final GeneratedColumn<String> accentColor = GeneratedColumn<String>(
    'accent_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    xp,
    level,
    streak,
    skillPoints,
    totalXp,
    availableSkillPoints,
    username,
    displayName,
    avatarUrl,
    lastActivityOn,
    goalSteps,
    goalWater,
    goalProtein,
    themeMode,
    accentColor,
    timezone,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedProfileEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    if (data.containsKey('skill_points')) {
      context.handle(
        _skillPointsMeta,
        skillPoints.isAcceptableOrUnknown(
          data['skill_points']!,
          _skillPointsMeta,
        ),
      );
    }
    if (data.containsKey('total_xp')) {
      context.handle(
        _totalXpMeta,
        totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta),
      );
    }
    if (data.containsKey('available_skill_points')) {
      context.handle(
        _availableSkillPointsMeta,
        availableSkillPoints.isAcceptableOrUnknown(
          data['available_skill_points']!,
          _availableSkillPointsMeta,
        ),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('last_activity_on')) {
      context.handle(
        _lastActivityOnMeta,
        lastActivityOn.isAcceptableOrUnknown(
          data['last_activity_on']!,
          _lastActivityOnMeta,
        ),
      );
    }
    if (data.containsKey('goal_steps')) {
      context.handle(
        _goalStepsMeta,
        goalSteps.isAcceptableOrUnknown(data['goal_steps']!, _goalStepsMeta),
      );
    }
    if (data.containsKey('goal_water')) {
      context.handle(
        _goalWaterMeta,
        goalWater.isAcceptableOrUnknown(data['goal_water']!, _goalWaterMeta),
      );
    }
    if (data.containsKey('goal_protein')) {
      context.handle(
        _goalProteinMeta,
        goalProtein.isAcceptableOrUnknown(
          data['goal_protein']!,
          _goalProteinMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('accent_color')) {
      context.handle(
        _accentColorMeta,
        accentColor.isAcceptableOrUnknown(
          data['accent_color']!,
          _accentColorMeta,
        ),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedProfileEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProfileEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
      skillPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skill_points'],
      )!,
      totalXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_xp'],
      )!,
      availableSkillPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_skill_points'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      lastActivityOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_activity_on'],
      ),
      goalSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_steps'],
      ),
      goalWater: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_water'],
      ),
      goalProtein: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_protein'],
      ),
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      ),
      accentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent_color'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      ),
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $CachedProfilesTable createAlias(String alias) {
    return $CachedProfilesTable(attachedDatabase, alias);
  }
}

class CachedProfileEntry extends DataClass
    implements Insertable<CachedProfileEntry> {
  final String id;
  final int xp;
  final int level;
  final int streak;
  final int skillPoints;
  final int totalXp;
  final int availableSkillPoints;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? lastActivityOn;
  final int? goalSteps;
  final double? goalWater;
  final int? goalProtein;
  final String? themeMode;
  final String? accentColor;
  final String? timezone;
  final DateTime lastUpdated;
  const CachedProfileEntry({
    required this.id,
    required this.xp,
    required this.level,
    required this.streak,
    required this.skillPoints,
    required this.totalXp,
    required this.availableSkillPoints,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.lastActivityOn,
    this.goalSteps,
    this.goalWater,
    this.goalProtein,
    this.themeMode,
    this.accentColor,
    this.timezone,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['xp'] = Variable<int>(xp);
    map['level'] = Variable<int>(level);
    map['streak'] = Variable<int>(streak);
    map['skill_points'] = Variable<int>(skillPoints);
    map['total_xp'] = Variable<int>(totalXp);
    map['available_skill_points'] = Variable<int>(availableSkillPoints);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || lastActivityOn != null) {
      map['last_activity_on'] = Variable<DateTime>(lastActivityOn);
    }
    if (!nullToAbsent || goalSteps != null) {
      map['goal_steps'] = Variable<int>(goalSteps);
    }
    if (!nullToAbsent || goalWater != null) {
      map['goal_water'] = Variable<double>(goalWater);
    }
    if (!nullToAbsent || goalProtein != null) {
      map['goal_protein'] = Variable<int>(goalProtein);
    }
    if (!nullToAbsent || themeMode != null) {
      map['theme_mode'] = Variable<String>(themeMode);
    }
    if (!nullToAbsent || accentColor != null) {
      map['accent_color'] = Variable<String>(accentColor);
    }
    if (!nullToAbsent || timezone != null) {
      map['timezone'] = Variable<String>(timezone);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  CachedProfilesCompanion toCompanion(bool nullToAbsent) {
    return CachedProfilesCompanion(
      id: Value(id),
      xp: Value(xp),
      level: Value(level),
      streak: Value(streak),
      skillPoints: Value(skillPoints),
      totalXp: Value(totalXp),
      availableSkillPoints: Value(availableSkillPoints),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      lastActivityOn: lastActivityOn == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivityOn),
      goalSteps: goalSteps == null && nullToAbsent
          ? const Value.absent()
          : Value(goalSteps),
      goalWater: goalWater == null && nullToAbsent
          ? const Value.absent()
          : Value(goalWater),
      goalProtein: goalProtein == null && nullToAbsent
          ? const Value.absent()
          : Value(goalProtein),
      themeMode: themeMode == null && nullToAbsent
          ? const Value.absent()
          : Value(themeMode),
      accentColor: accentColor == null && nullToAbsent
          ? const Value.absent()
          : Value(accentColor),
      timezone: timezone == null && nullToAbsent
          ? const Value.absent()
          : Value(timezone),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory CachedProfileEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProfileEntry(
      id: serializer.fromJson<String>(json['id']),
      xp: serializer.fromJson<int>(json['xp']),
      level: serializer.fromJson<int>(json['level']),
      streak: serializer.fromJson<int>(json['streak']),
      skillPoints: serializer.fromJson<int>(json['skillPoints']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      availableSkillPoints: serializer.fromJson<int>(
        json['availableSkillPoints'],
      ),
      username: serializer.fromJson<String?>(json['username']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      lastActivityOn: serializer.fromJson<DateTime?>(json['lastActivityOn']),
      goalSteps: serializer.fromJson<int?>(json['goalSteps']),
      goalWater: serializer.fromJson<double?>(json['goalWater']),
      goalProtein: serializer.fromJson<int?>(json['goalProtein']),
      themeMode: serializer.fromJson<String?>(json['themeMode']),
      accentColor: serializer.fromJson<String?>(json['accentColor']),
      timezone: serializer.fromJson<String?>(json['timezone']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'xp': serializer.toJson<int>(xp),
      'level': serializer.toJson<int>(level),
      'streak': serializer.toJson<int>(streak),
      'skillPoints': serializer.toJson<int>(skillPoints),
      'totalXp': serializer.toJson<int>(totalXp),
      'availableSkillPoints': serializer.toJson<int>(availableSkillPoints),
      'username': serializer.toJson<String?>(username),
      'displayName': serializer.toJson<String?>(displayName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'lastActivityOn': serializer.toJson<DateTime?>(lastActivityOn),
      'goalSteps': serializer.toJson<int?>(goalSteps),
      'goalWater': serializer.toJson<double?>(goalWater),
      'goalProtein': serializer.toJson<int?>(goalProtein),
      'themeMode': serializer.toJson<String?>(themeMode),
      'accentColor': serializer.toJson<String?>(accentColor),
      'timezone': serializer.toJson<String?>(timezone),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  CachedProfileEntry copyWith({
    String? id,
    int? xp,
    int? level,
    int? streak,
    int? skillPoints,
    int? totalXp,
    int? availableSkillPoints,
    Value<String?> username = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    Value<DateTime?> lastActivityOn = const Value.absent(),
    Value<int?> goalSteps = const Value.absent(),
    Value<double?> goalWater = const Value.absent(),
    Value<int?> goalProtein = const Value.absent(),
    Value<String?> themeMode = const Value.absent(),
    Value<String?> accentColor = const Value.absent(),
    Value<String?> timezone = const Value.absent(),
    DateTime? lastUpdated,
  }) => CachedProfileEntry(
    id: id ?? this.id,
    xp: xp ?? this.xp,
    level: level ?? this.level,
    streak: streak ?? this.streak,
    skillPoints: skillPoints ?? this.skillPoints,
    totalXp: totalXp ?? this.totalXp,
    availableSkillPoints: availableSkillPoints ?? this.availableSkillPoints,
    username: username.present ? username.value : this.username,
    displayName: displayName.present ? displayName.value : this.displayName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    lastActivityOn: lastActivityOn.present
        ? lastActivityOn.value
        : this.lastActivityOn,
    goalSteps: goalSteps.present ? goalSteps.value : this.goalSteps,
    goalWater: goalWater.present ? goalWater.value : this.goalWater,
    goalProtein: goalProtein.present ? goalProtein.value : this.goalProtein,
    themeMode: themeMode.present ? themeMode.value : this.themeMode,
    accentColor: accentColor.present ? accentColor.value : this.accentColor,
    timezone: timezone.present ? timezone.value : this.timezone,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  CachedProfileEntry copyWithCompanion(CachedProfilesCompanion data) {
    return CachedProfileEntry(
      id: data.id.present ? data.id.value : this.id,
      xp: data.xp.present ? data.xp.value : this.xp,
      level: data.level.present ? data.level.value : this.level,
      streak: data.streak.present ? data.streak.value : this.streak,
      skillPoints: data.skillPoints.present
          ? data.skillPoints.value
          : this.skillPoints,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      availableSkillPoints: data.availableSkillPoints.present
          ? data.availableSkillPoints.value
          : this.availableSkillPoints,
      username: data.username.present ? data.username.value : this.username,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      lastActivityOn: data.lastActivityOn.present
          ? data.lastActivityOn.value
          : this.lastActivityOn,
      goalSteps: data.goalSteps.present ? data.goalSteps.value : this.goalSteps,
      goalWater: data.goalWater.present ? data.goalWater.value : this.goalWater,
      goalProtein: data.goalProtein.present
          ? data.goalProtein.value
          : this.goalProtein,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      accentColor: data.accentColor.present
          ? data.accentColor.value
          : this.accentColor,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfileEntry(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('level: $level, ')
          ..write('streak: $streak, ')
          ..write('skillPoints: $skillPoints, ')
          ..write('totalXp: $totalXp, ')
          ..write('availableSkillPoints: $availableSkillPoints, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastActivityOn: $lastActivityOn, ')
          ..write('goalSteps: $goalSteps, ')
          ..write('goalWater: $goalWater, ')
          ..write('goalProtein: $goalProtein, ')
          ..write('themeMode: $themeMode, ')
          ..write('accentColor: $accentColor, ')
          ..write('timezone: $timezone, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    xp,
    level,
    streak,
    skillPoints,
    totalXp,
    availableSkillPoints,
    username,
    displayName,
    avatarUrl,
    lastActivityOn,
    goalSteps,
    goalWater,
    goalProtein,
    themeMode,
    accentColor,
    timezone,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProfileEntry &&
          other.id == this.id &&
          other.xp == this.xp &&
          other.level == this.level &&
          other.streak == this.streak &&
          other.skillPoints == this.skillPoints &&
          other.totalXp == this.totalXp &&
          other.availableSkillPoints == this.availableSkillPoints &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.avatarUrl == this.avatarUrl &&
          other.lastActivityOn == this.lastActivityOn &&
          other.goalSteps == this.goalSteps &&
          other.goalWater == this.goalWater &&
          other.goalProtein == this.goalProtein &&
          other.themeMode == this.themeMode &&
          other.accentColor == this.accentColor &&
          other.timezone == this.timezone &&
          other.lastUpdated == this.lastUpdated);
}

class CachedProfilesCompanion extends UpdateCompanion<CachedProfileEntry> {
  final Value<String> id;
  final Value<int> xp;
  final Value<int> level;
  final Value<int> streak;
  final Value<int> skillPoints;
  final Value<int> totalXp;
  final Value<int> availableSkillPoints;
  final Value<String?> username;
  final Value<String?> displayName;
  final Value<String?> avatarUrl;
  final Value<DateTime?> lastActivityOn;
  final Value<int?> goalSteps;
  final Value<double?> goalWater;
  final Value<int?> goalProtein;
  final Value<String?> themeMode;
  final Value<String?> accentColor;
  final Value<String?> timezone;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const CachedProfilesCompanion({
    this.id = const Value.absent(),
    this.xp = const Value.absent(),
    this.level = const Value.absent(),
    this.streak = const Value.absent(),
    this.skillPoints = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.availableSkillPoints = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.lastActivityOn = const Value.absent(),
    this.goalSteps = const Value.absent(),
    this.goalWater = const Value.absent(),
    this.goalProtein = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.timezone = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProfilesCompanion.insert({
    required String id,
    this.xp = const Value.absent(),
    this.level = const Value.absent(),
    this.streak = const Value.absent(),
    this.skillPoints = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.availableSkillPoints = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.lastActivityOn = const Value.absent(),
    this.goalSteps = const Value.absent(),
    this.goalWater = const Value.absent(),
    this.goalProtein = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.timezone = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<CachedProfileEntry> custom({
    Expression<String>? id,
    Expression<int>? xp,
    Expression<int>? level,
    Expression<int>? streak,
    Expression<int>? skillPoints,
    Expression<int>? totalXp,
    Expression<int>? availableSkillPoints,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? avatarUrl,
    Expression<DateTime>? lastActivityOn,
    Expression<int>? goalSteps,
    Expression<double>? goalWater,
    Expression<int>? goalProtein,
    Expression<String>? themeMode,
    Expression<String>? accentColor,
    Expression<String>? timezone,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (xp != null) 'xp': xp,
      if (level != null) 'level': level,
      if (streak != null) 'streak': streak,
      if (skillPoints != null) 'skill_points': skillPoints,
      if (totalXp != null) 'total_xp': totalXp,
      if (availableSkillPoints != null)
        'available_skill_points': availableSkillPoints,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (lastActivityOn != null) 'last_activity_on': lastActivityOn,
      if (goalSteps != null) 'goal_steps': goalSteps,
      if (goalWater != null) 'goal_water': goalWater,
      if (goalProtein != null) 'goal_protein': goalProtein,
      if (themeMode != null) 'theme_mode': themeMode,
      if (accentColor != null) 'accent_color': accentColor,
      if (timezone != null) 'timezone': timezone,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProfilesCompanion copyWith({
    Value<String>? id,
    Value<int>? xp,
    Value<int>? level,
    Value<int>? streak,
    Value<int>? skillPoints,
    Value<int>? totalXp,
    Value<int>? availableSkillPoints,
    Value<String?>? username,
    Value<String?>? displayName,
    Value<String?>? avatarUrl,
    Value<DateTime?>? lastActivityOn,
    Value<int?>? goalSteps,
    Value<double?>? goalWater,
    Value<int?>? goalProtein,
    Value<String?>? themeMode,
    Value<String?>? accentColor,
    Value<String?>? timezone,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return CachedProfilesCompanion(
      id: id ?? this.id,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      skillPoints: skillPoints ?? this.skillPoints,
      totalXp: totalXp ?? this.totalXp,
      availableSkillPoints: availableSkillPoints ?? this.availableSkillPoints,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastActivityOn: lastActivityOn ?? this.lastActivityOn,
      goalSteps: goalSteps ?? this.goalSteps,
      goalWater: goalWater ?? this.goalWater,
      goalProtein: goalProtein ?? this.goalProtein,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      timezone: timezone ?? this.timezone,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (skillPoints.present) {
      map['skill_points'] = Variable<int>(skillPoints.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (availableSkillPoints.present) {
      map['available_skill_points'] = Variable<int>(availableSkillPoints.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (lastActivityOn.present) {
      map['last_activity_on'] = Variable<DateTime>(lastActivityOn.value);
    }
    if (goalSteps.present) {
      map['goal_steps'] = Variable<int>(goalSteps.value);
    }
    if (goalWater.present) {
      map['goal_water'] = Variable<double>(goalWater.value);
    }
    if (goalProtein.present) {
      map['goal_protein'] = Variable<int>(goalProtein.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (accentColor.present) {
      map['accent_color'] = Variable<String>(accentColor.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfilesCompanion(')
          ..write('id: $id, ')
          ..write('xp: $xp, ')
          ..write('level: $level, ')
          ..write('streak: $streak, ')
          ..write('skillPoints: $skillPoints, ')
          ..write('totalXp: $totalXp, ')
          ..write('availableSkillPoints: $availableSkillPoints, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('lastActivityOn: $lastActivityOn, ')
          ..write('goalSteps: $goalSteps, ')
          ..write('goalWater: $goalWater, ')
          ..write('goalProtein: $goalProtein, ')
          ..write('themeMode: $themeMode, ')
          ..write('accentColor: $accentColor, ')
          ..write('timezone: $timezone, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    action,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int id;
  final String entityType;
  final String action;
  final String payload;
  final DateTime createdAt;
  const SyncQueueEntry({
    required this.id,
    required this.entityType,
    required this.action,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueEntry copyWith({
    int? id,
    String? entityType,
    String? action,
    String? payload,
    DateTime? createdAt,
  }) => SyncQueueEntry(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, action, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String action,
    required String payload,
    this.createdAt = const Value.absent(),
  }) : entityType = Value(entityType),
       action = Value(action),
       payload = Value(payload);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? action,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CachedMedalsTable extends CachedMedals
    with TableInfo<$CachedMedalsTable, CachedMedalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMedalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medalIdMeta = const VerificationMeta(
    'medalId',
  );
  @override
  late final GeneratedColumn<String> medalId = GeneratedColumn<String>(
    'medal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, medalId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_medals';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMedalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('medal_id')) {
      context.handle(
        _medalIdMeta,
        medalId.isAcceptableOrUnknown(data['medal_id']!, _medalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medalIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, medalId};
  @override
  CachedMedalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMedalEntry(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      medalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medal_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $CachedMedalsTable createAlias(String alias) {
    return $CachedMedalsTable(attachedDatabase, alias);
  }
}

class CachedMedalEntry extends DataClass
    implements Insertable<CachedMedalEntry> {
  final String userId;
  final String medalId;
  final DateTime unlockedAt;
  const CachedMedalEntry({
    required this.userId,
    required this.medalId,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['medal_id'] = Variable<String>(medalId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  CachedMedalsCompanion toCompanion(bool nullToAbsent) {
    return CachedMedalsCompanion(
      userId: Value(userId),
      medalId: Value(medalId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory CachedMedalEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMedalEntry(
      userId: serializer.fromJson<String>(json['userId']),
      medalId: serializer.fromJson<String>(json['medalId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'medalId': serializer.toJson<String>(medalId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  CachedMedalEntry copyWith({
    String? userId,
    String? medalId,
    DateTime? unlockedAt,
  }) => CachedMedalEntry(
    userId: userId ?? this.userId,
    medalId: medalId ?? this.medalId,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  CachedMedalEntry copyWithCompanion(CachedMedalsCompanion data) {
    return CachedMedalEntry(
      userId: data.userId.present ? data.userId.value : this.userId,
      medalId: data.medalId.present ? data.medalId.value : this.medalId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMedalEntry(')
          ..write('userId: $userId, ')
          ..write('medalId: $medalId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, medalId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMedalEntry &&
          other.userId == this.userId &&
          other.medalId == this.medalId &&
          other.unlockedAt == this.unlockedAt);
}

class CachedMedalsCompanion extends UpdateCompanion<CachedMedalEntry> {
  final Value<String> userId;
  final Value<String> medalId;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const CachedMedalsCompanion({
    this.userId = const Value.absent(),
    this.medalId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMedalsCompanion.insert({
    required String userId,
    required String medalId,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       medalId = Value(medalId),
       unlockedAt = Value(unlockedAt);
  static Insertable<CachedMedalEntry> custom({
    Expression<String>? userId,
    Expression<String>? medalId,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (medalId != null) 'medal_id': medalId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMedalsCompanion copyWith({
    Value<String>? userId,
    Value<String>? medalId,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return CachedMedalsCompanion(
      userId: userId ?? this.userId,
      medalId: medalId ?? this.medalId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (medalId.present) {
      map['medal_id'] = Variable<String>(medalId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMedalsCompanion(')
          ..write('userId: $userId, ')
          ..write('medalId: $medalId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSkillsTable extends CachedSkills
    with TableInfo<$CachedSkillsTable, CachedSkillEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSkillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<String> muscleGroup = GeneratedColumn<String>(
    'muscle_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [userId, muscleGroup, points];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_skills';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSkillEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, muscleGroup};
  @override
  CachedSkillEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSkillEntry(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
    );
  }

  @override
  $CachedSkillsTable createAlias(String alias) {
    return $CachedSkillsTable(attachedDatabase, alias);
  }
}

class CachedSkillEntry extends DataClass
    implements Insertable<CachedSkillEntry> {
  final String userId;
  final String muscleGroup;
  final int points;
  const CachedSkillEntry({
    required this.userId,
    required this.muscleGroup,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['muscle_group'] = Variable<String>(muscleGroup);
    map['points'] = Variable<int>(points);
    return map;
  }

  CachedSkillsCompanion toCompanion(bool nullToAbsent) {
    return CachedSkillsCompanion(
      userId: Value(userId),
      muscleGroup: Value(muscleGroup),
      points: Value(points),
    );
  }

  factory CachedSkillEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSkillEntry(
      userId: serializer.fromJson<String>(json['userId']),
      muscleGroup: serializer.fromJson<String>(json['muscleGroup']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'muscleGroup': serializer.toJson<String>(muscleGroup),
      'points': serializer.toJson<int>(points),
    };
  }

  CachedSkillEntry copyWith({
    String? userId,
    String? muscleGroup,
    int? points,
  }) => CachedSkillEntry(
    userId: userId ?? this.userId,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    points: points ?? this.points,
  );
  CachedSkillEntry copyWithCompanion(CachedSkillsCompanion data) {
    return CachedSkillEntry(
      userId: data.userId.present ? data.userId.value : this.userId,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSkillEntry(')
          ..write('userId: $userId, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, muscleGroup, points);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSkillEntry &&
          other.userId == this.userId &&
          other.muscleGroup == this.muscleGroup &&
          other.points == this.points);
}

class CachedSkillsCompanion extends UpdateCompanion<CachedSkillEntry> {
  final Value<String> userId;
  final Value<String> muscleGroup;
  final Value<int> points;
  final Value<int> rowid;
  const CachedSkillsCompanion({
    this.userId = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.points = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSkillsCompanion.insert({
    required String userId,
    required String muscleGroup,
    this.points = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       muscleGroup = Value(muscleGroup);
  static Insertable<CachedSkillEntry> custom({
    Expression<String>? userId,
    Expression<String>? muscleGroup,
    Expression<int>? points,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (points != null) 'points': points,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSkillsCompanion copyWith({
    Value<String>? userId,
    Value<String>? muscleGroup,
    Value<int>? points,
    Value<int>? rowid,
  }) {
    return CachedSkillsCompanion(
      userId: userId ?? this.userId,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      points: points ?? this.points,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(muscleGroup.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSkillsCompanion(')
          ..write('userId: $userId, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('points: $points, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedWorkoutsTable extends CachedWorkouts
    with TableInfo<$CachedWorkoutsTable, CachedWorkoutEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedWorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineNameMeta = const VerificationMeta(
    'routineName',
  );
  @override
  late final GeneratedColumn<String> routineName = GeneratedColumn<String>(
    'routine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalVolumeKgMeta = const VerificationMeta(
    'totalVolumeKg',
  );
  @override
  late final GeneratedColumn<double> totalVolumeKg = GeneratedColumn<double>(
    'total_volume_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawPayloadMeta = const VerificationMeta(
    'rawPayload',
  );
  @override
  late final GeneratedColumn<String> rawPayload = GeneratedColumn<String>(
    'raw_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    routineName,
    startedAt,
    completedAt,
    durationSeconds,
    totalVolumeKg,
    rawPayload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedWorkoutEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('routine_name')) {
      context.handle(
        _routineNameMeta,
        routineName.isAcceptableOrUnknown(
          data['routine_name']!,
          _routineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('total_volume_kg')) {
      context.handle(
        _totalVolumeKgMeta,
        totalVolumeKg.isAcceptableOrUnknown(
          data['total_volume_kg']!,
          _totalVolumeKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalVolumeKgMeta);
    }
    if (data.containsKey('raw_payload')) {
      context.handle(
        _rawPayloadMeta,
        rawPayload.isAcceptableOrUnknown(data['raw_payload']!, _rawPayloadMeta),
      );
    } else if (isInserting) {
      context.missing(_rawPayloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedWorkoutEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedWorkoutEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      routineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      totalVolumeKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_volume_kg'],
      )!,
      rawPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_payload'],
      )!,
    );
  }

  @override
  $CachedWorkoutsTable createAlias(String alias) {
    return $CachedWorkoutsTable(attachedDatabase, alias);
  }
}

class CachedWorkoutEntry extends DataClass
    implements Insertable<CachedWorkoutEntry> {
  final String id;
  final String userId;
  final String routineName;
  final DateTime? startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final double totalVolumeKg;
  final String rawPayload;
  const CachedWorkoutEntry({
    required this.id,
    required this.userId,
    required this.routineName,
    this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.totalVolumeKg,
    required this.rawPayload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['routine_name'] = Variable<String>(routineName);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['total_volume_kg'] = Variable<double>(totalVolumeKg);
    map['raw_payload'] = Variable<String>(rawPayload);
    return map;
  }

  CachedWorkoutsCompanion toCompanion(bool nullToAbsent) {
    return CachedWorkoutsCompanion(
      id: Value(id),
      userId: Value(userId),
      routineName: Value(routineName),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: Value(completedAt),
      durationSeconds: Value(durationSeconds),
      totalVolumeKg: Value(totalVolumeKg),
      rawPayload: Value(rawPayload),
    );
  }

  factory CachedWorkoutEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedWorkoutEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      routineName: serializer.fromJson<String>(json['routineName']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      totalVolumeKg: serializer.fromJson<double>(json['totalVolumeKg']),
      rawPayload: serializer.fromJson<String>(json['rawPayload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'routineName': serializer.toJson<String>(routineName),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'totalVolumeKg': serializer.toJson<double>(totalVolumeKg),
      'rawPayload': serializer.toJson<String>(rawPayload),
    };
  }

  CachedWorkoutEntry copyWith({
    String? id,
    String? userId,
    String? routineName,
    Value<DateTime?> startedAt = const Value.absent(),
    DateTime? completedAt,
    int? durationSeconds,
    double? totalVolumeKg,
    String? rawPayload,
  }) => CachedWorkoutEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    routineName: routineName ?? this.routineName,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
    rawPayload: rawPayload ?? this.rawPayload,
  );
  CachedWorkoutEntry copyWithCompanion(CachedWorkoutsCompanion data) {
    return CachedWorkoutEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      routineName: data.routineName.present
          ? data.routineName.value
          : this.routineName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      totalVolumeKg: data.totalVolumeKg.present
          ? data.totalVolumeKg.value
          : this.totalVolumeKg,
      rawPayload: data.rawPayload.present
          ? data.rawPayload.value
          : this.rawPayload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedWorkoutEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('routineName: $routineName, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('totalVolumeKg: $totalVolumeKg, ')
          ..write('rawPayload: $rawPayload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    routineName,
    startedAt,
    completedAt,
    durationSeconds,
    totalVolumeKg,
    rawPayload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedWorkoutEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.routineName == this.routineName &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.totalVolumeKg == this.totalVolumeKg &&
          other.rawPayload == this.rawPayload);
}

class CachedWorkoutsCompanion extends UpdateCompanion<CachedWorkoutEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> routineName;
  final Value<DateTime?> startedAt;
  final Value<DateTime> completedAt;
  final Value<int> durationSeconds;
  final Value<double> totalVolumeKg;
  final Value<String> rawPayload;
  final Value<int> rowid;
  const CachedWorkoutsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.routineName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.totalVolumeKg = const Value.absent(),
    this.rawPayload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedWorkoutsCompanion.insert({
    required String id,
    required String userId,
    required String routineName,
    this.startedAt = const Value.absent(),
    required DateTime completedAt,
    required int durationSeconds,
    required double totalVolumeKg,
    required String rawPayload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       routineName = Value(routineName),
       completedAt = Value(completedAt),
       durationSeconds = Value(durationSeconds),
       totalVolumeKg = Value(totalVolumeKg),
       rawPayload = Value(rawPayload);
  static Insertable<CachedWorkoutEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? routineName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? durationSeconds,
    Expression<double>? totalVolumeKg,
    Expression<String>? rawPayload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (routineName != null) 'routine_name': routineName,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (totalVolumeKg != null) 'total_volume_kg': totalVolumeKg,
      if (rawPayload != null) 'raw_payload': rawPayload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedWorkoutsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? routineName,
    Value<DateTime?>? startedAt,
    Value<DateTime>? completedAt,
    Value<int>? durationSeconds,
    Value<double>? totalVolumeKg,
    Value<String>? rawPayload,
    Value<int>? rowid,
  }) {
    return CachedWorkoutsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routineName: routineName ?? this.routineName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
      rawPayload: rawPayload ?? this.rawPayload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (routineName.present) {
      map['routine_name'] = Variable<String>(routineName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (totalVolumeKg.present) {
      map['total_volume_kg'] = Variable<double>(totalVolumeKg.value);
    }
    if (rawPayload.present) {
      map['raw_payload'] = Variable<String>(rawPayload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedWorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('routineName: $routineName, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('totalVolumeKg: $totalVolumeKg, ')
          ..write('rawPayload: $rawPayload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedQuestsTable extends CachedQuests
    with TableInfo<$CachedQuestsTable, CachedQuestEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedQuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questTypeMeta = const VerificationMeta(
    'questType',
  );
  @override
  late final GeneratedColumn<String> questType = GeneratedColumn<String>(
    'quest_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xpRewardMeta = const VerificationMeta(
    'xpReward',
  );
  @override
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
    'xp_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMetricMeta = const VerificationMeta(
    'targetMetric',
  );
  @override
  late final GeneratedColumn<String> targetMetric = GeneratedColumn<String>(
    'target_metric',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
    'target_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    questType,
    title,
    description,
    xpReward,
    targetMetric,
    targetValue,
    exerciseName,
    expiresAt,
    createdAt,
    isCompleted,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedQuestEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('quest_type')) {
      context.handle(
        _questTypeMeta,
        questType.isAcceptableOrUnknown(data['quest_type']!, _questTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_questTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    } else if (isInserting) {
      context.missing(_xpRewardMeta);
    }
    if (data.containsKey('target_metric')) {
      context.handle(
        _targetMetricMeta,
        targetMetric.isAcceptableOrUnknown(
          data['target_metric']!,
          _targetMetricMeta,
        ),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedQuestEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedQuestEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      questType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      targetMetric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_metric'],
      ),
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_value'],
      ),
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $CachedQuestsTable createAlias(String alias) {
    return $CachedQuestsTable(attachedDatabase, alias);
  }
}

class CachedQuestEntry extends DataClass
    implements Insertable<CachedQuestEntry> {
  final String id;
  final String userId;
  final String questType;
  final String title;
  final String description;
  final int xpReward;
  final String? targetMetric;
  final double? targetValue;
  final String? exerciseName;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;
  const CachedQuestEntry({
    required this.id,
    required this.userId,
    required this.questType,
    required this.title,
    required this.description,
    required this.xpReward,
    this.targetMetric,
    this.targetValue,
    this.exerciseName,
    required this.expiresAt,
    required this.createdAt,
    required this.isCompleted,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['quest_type'] = Variable<String>(questType);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['xp_reward'] = Variable<int>(xpReward);
    if (!nullToAbsent || targetMetric != null) {
      map['target_metric'] = Variable<String>(targetMetric);
    }
    if (!nullToAbsent || targetValue != null) {
      map['target_value'] = Variable<double>(targetValue);
    }
    if (!nullToAbsent || exerciseName != null) {
      map['exercise_name'] = Variable<String>(exerciseName);
    }
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  CachedQuestsCompanion toCompanion(bool nullToAbsent) {
    return CachedQuestsCompanion(
      id: Value(id),
      userId: Value(userId),
      questType: Value(questType),
      title: Value(title),
      description: Value(description),
      xpReward: Value(xpReward),
      targetMetric: targetMetric == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMetric),
      targetValue: targetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(targetValue),
      exerciseName: exerciseName == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseName),
      expiresAt: Value(expiresAt),
      createdAt: Value(createdAt),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory CachedQuestEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedQuestEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      questType: serializer.fromJson<String>(json['questType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      xpReward: serializer.fromJson<int>(json['xpReward']),
      targetMetric: serializer.fromJson<String?>(json['targetMetric']),
      targetValue: serializer.fromJson<double?>(json['targetValue']),
      exerciseName: serializer.fromJson<String?>(json['exerciseName']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'questType': serializer.toJson<String>(questType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'xpReward': serializer.toJson<int>(xpReward),
      'targetMetric': serializer.toJson<String?>(targetMetric),
      'targetValue': serializer.toJson<double?>(targetValue),
      'exerciseName': serializer.toJson<String?>(exerciseName),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  CachedQuestEntry copyWith({
    String? id,
    String? userId,
    String? questType,
    String? title,
    String? description,
    int? xpReward,
    Value<String?> targetMetric = const Value.absent(),
    Value<double?> targetValue = const Value.absent(),
    Value<String?> exerciseName = const Value.absent(),
    DateTime? expiresAt,
    DateTime? createdAt,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => CachedQuestEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    questType: questType ?? this.questType,
    title: title ?? this.title,
    description: description ?? this.description,
    xpReward: xpReward ?? this.xpReward,
    targetMetric: targetMetric.present ? targetMetric.value : this.targetMetric,
    targetValue: targetValue.present ? targetValue.value : this.targetValue,
    exerciseName: exerciseName.present ? exerciseName.value : this.exerciseName,
    expiresAt: expiresAt ?? this.expiresAt,
    createdAt: createdAt ?? this.createdAt,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  CachedQuestEntry copyWithCompanion(CachedQuestsCompanion data) {
    return CachedQuestEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      questType: data.questType.present ? data.questType.value : this.questType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      targetMetric: data.targetMetric.present
          ? data.targetMetric.value
          : this.targetMetric,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedQuestEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('questType: $questType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('xpReward: $xpReward, ')
          ..write('targetMetric: $targetMetric, ')
          ..write('targetValue: $targetValue, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    questType,
    title,
    description,
    xpReward,
    targetMetric,
    targetValue,
    exerciseName,
    expiresAt,
    createdAt,
    isCompleted,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedQuestEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.questType == this.questType &&
          other.title == this.title &&
          other.description == this.description &&
          other.xpReward == this.xpReward &&
          other.targetMetric == this.targetMetric &&
          other.targetValue == this.targetValue &&
          other.exerciseName == this.exerciseName &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt);
}

class CachedQuestsCompanion extends UpdateCompanion<CachedQuestEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> questType;
  final Value<String> title;
  final Value<String> description;
  final Value<int> xpReward;
  final Value<String?> targetMetric;
  final Value<double?> targetValue;
  final Value<String?> exerciseName;
  final Value<DateTime> expiresAt;
  final Value<DateTime> createdAt;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const CachedQuestsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.questType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.targetMetric = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedQuestsCompanion.insert({
    required String id,
    required String userId,
    required String questType,
    required String title,
    required String description,
    required int xpReward,
    this.targetMetric = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.exerciseName = const Value.absent(),
    required DateTime expiresAt,
    this.createdAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       questType = Value(questType),
       title = Value(title),
       description = Value(description),
       xpReward = Value(xpReward),
       expiresAt = Value(expiresAt);
  static Insertable<CachedQuestEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? questType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? xpReward,
    Expression<String>? targetMetric,
    Expression<double>? targetValue,
    Expression<String>? exerciseName,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? createdAt,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (questType != null) 'quest_type': questType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (xpReward != null) 'xp_reward': xpReward,
      if (targetMetric != null) 'target_metric': targetMetric,
      if (targetValue != null) 'target_value': targetValue,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedQuestsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? questType,
    Value<String>? title,
    Value<String>? description,
    Value<int>? xpReward,
    Value<String?>? targetMetric,
    Value<double?>? targetValue,
    Value<String?>? exerciseName,
    Value<DateTime>? expiresAt,
    Value<DateTime>? createdAt,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return CachedQuestsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questType: questType ?? this.questType,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      targetMetric: targetMetric ?? this.targetMetric,
      targetValue: targetValue ?? this.targetValue,
      exerciseName: exerciseName ?? this.exerciseName,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (questType.present) {
      map['quest_type'] = Variable<String>(questType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (targetMetric.present) {
      map['target_metric'] = Variable<String>(targetMetric.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedQuestsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('questType: $questType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('xpReward: $xpReward, ')
          ..write('targetMetric: $targetMetric, ')
          ..write('targetValue: $targetValue, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedProfilesTable cachedProfiles = $CachedProfilesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $CachedMedalsTable cachedMedals = $CachedMedalsTable(this);
  late final $CachedSkillsTable cachedSkills = $CachedSkillsTable(this);
  late final $CachedWorkoutsTable cachedWorkouts = $CachedWorkoutsTable(this);
  late final $CachedQuestsTable cachedQuests = $CachedQuestsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedProfiles,
    syncQueue,
    cachedMedals,
    cachedSkills,
    cachedWorkouts,
    cachedQuests,
  ];
}

typedef $$CachedProfilesTableCreateCompanionBuilder =
    CachedProfilesCompanion Function({
      required String id,
      Value<int> xp,
      Value<int> level,
      Value<int> streak,
      Value<int> skillPoints,
      Value<int> totalXp,
      Value<int> availableSkillPoints,
      Value<String?> username,
      Value<String?> displayName,
      Value<String?> avatarUrl,
      Value<DateTime?> lastActivityOn,
      Value<int?> goalSteps,
      Value<double?> goalWater,
      Value<int?> goalProtein,
      Value<String?> themeMode,
      Value<String?> accentColor,
      Value<String?> timezone,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });
typedef $$CachedProfilesTableUpdateCompanionBuilder =
    CachedProfilesCompanion Function({
      Value<String> id,
      Value<int> xp,
      Value<int> level,
      Value<int> streak,
      Value<int> skillPoints,
      Value<int> totalXp,
      Value<int> availableSkillPoints,
      Value<String?> username,
      Value<String?> displayName,
      Value<String?> avatarUrl,
      Value<DateTime?> lastActivityOn,
      Value<int?> goalSteps,
      Value<double?> goalWater,
      Value<int?> goalProtein,
      Value<String?> themeMode,
      Value<String?> accentColor,
      Value<String?> timezone,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

class $$CachedProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skillPoints => $composableBuilder(
    column: $table.skillPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableSkillPoints => $composableBuilder(
    column: $table.availableSkillPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActivityOn => $composableBuilder(
    column: $table.lastActivityOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalSteps => $composableBuilder(
    column: $table.goalSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goalWater => $composableBuilder(
    column: $table.goalWater,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalProtein => $composableBuilder(
    column: $table.goalProtein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skillPoints => $composableBuilder(
    column: $table.skillPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalXp => $composableBuilder(
    column: $table.totalXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableSkillPoints => $composableBuilder(
    column: $table.availableSkillPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActivityOn => $composableBuilder(
    column: $table.lastActivityOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalSteps => $composableBuilder(
    column: $table.goalSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goalWater => $composableBuilder(
    column: $table.goalWater,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalProtein => $composableBuilder(
    column: $table.goalProtein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<int> get skillPoints => $composableBuilder(
    column: $table.skillPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get availableSkillPoints => $composableBuilder(
    column: $table.availableSkillPoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActivityOn => $composableBuilder(
    column: $table.lastActivityOn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalSteps =>
      $composableBuilder(column: $table.goalSteps, builder: (column) => column);

  GeneratedColumn<double> get goalWater =>
      $composableBuilder(column: $table.goalWater, builder: (column) => column);

  GeneratedColumn<int> get goalProtein => $composableBuilder(
    column: $table.goalProtein,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$CachedProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedProfilesTable,
          CachedProfileEntry,
          $$CachedProfilesTableFilterComposer,
          $$CachedProfilesTableOrderingComposer,
          $$CachedProfilesTableAnnotationComposer,
          $$CachedProfilesTableCreateCompanionBuilder,
          $$CachedProfilesTableUpdateCompanionBuilder,
          (
            CachedProfileEntry,
            BaseReferences<
              _$AppDatabase,
              $CachedProfilesTable,
              CachedProfileEntry
            >,
          ),
          CachedProfileEntry,
          PrefetchHooks Function()
        > {
  $$CachedProfilesTableTableManager(
    _$AppDatabase db,
    $CachedProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> skillPoints = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> availableSkillPoints = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime?> lastActivityOn = const Value.absent(),
                Value<int?> goalSteps = const Value.absent(),
                Value<double?> goalWater = const Value.absent(),
                Value<int?> goalProtein = const Value.absent(),
                Value<String?> themeMode = const Value.absent(),
                Value<String?> accentColor = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProfilesCompanion(
                id: id,
                xp: xp,
                level: level,
                streak: streak,
                skillPoints: skillPoints,
                totalXp: totalXp,
                availableSkillPoints: availableSkillPoints,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                lastActivityOn: lastActivityOn,
                goalSteps: goalSteps,
                goalWater: goalWater,
                goalProtein: goalProtein,
                themeMode: themeMode,
                accentColor: accentColor,
                timezone: timezone,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> xp = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> streak = const Value.absent(),
                Value<int> skillPoints = const Value.absent(),
                Value<int> totalXp = const Value.absent(),
                Value<int> availableSkillPoints = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime?> lastActivityOn = const Value.absent(),
                Value<int?> goalSteps = const Value.absent(),
                Value<double?> goalWater = const Value.absent(),
                Value<int?> goalProtein = const Value.absent(),
                Value<String?> themeMode = const Value.absent(),
                Value<String?> accentColor = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedProfilesCompanion.insert(
                id: id,
                xp: xp,
                level: level,
                streak: streak,
                skillPoints: skillPoints,
                totalXp: totalXp,
                availableSkillPoints: availableSkillPoints,
                username: username,
                displayName: displayName,
                avatarUrl: avatarUrl,
                lastActivityOn: lastActivityOn,
                goalSteps: goalSteps,
                goalWater: goalWater,
                goalProtein: goalProtein,
                themeMode: themeMode,
                accentColor: accentColor,
                timezone: timezone,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedProfilesTable, CachedProfileEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedProfilesTable,
                    CachedProfileEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedProfilesTable,
      CachedProfileEntry,
      $$CachedProfilesTableFilterComposer,
      $$CachedProfilesTableOrderingComposer,
      $$CachedProfilesTableAnnotationComposer,
      $$CachedProfilesTableCreateCompanionBuilder,
      $$CachedProfilesTableUpdateCompanionBuilder,
      (
        CachedProfileEntry,
        BaseReferences<_$AppDatabase, $CachedProfilesTable, CachedProfileEntry>,
      ),
      CachedProfileEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String entityType,
      required String action,
      required String payload,
      Value<DateTime> createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> action,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueEntry,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntry>,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                action: action,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String action,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                action: action,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncQueueTable, SyncQueueEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncQueueTable,
                    SyncQueueEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueEntry,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedMedalsTableCreateCompanionBuilder =
    CachedMedalsCompanion Function({
      required String userId,
      required String medalId,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$CachedMedalsTableUpdateCompanionBuilder =
    CachedMedalsCompanion Function({
      Value<String> userId,
      Value<String> medalId,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$CachedMedalsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMedalsTable> {
  $$CachedMedalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medalId => $composableBuilder(
    column: $table.medalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedMedalsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMedalsTable> {
  $$CachedMedalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medalId => $composableBuilder(
    column: $table.medalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedMedalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMedalsTable> {
  $$CachedMedalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get medalId =>
      $composableBuilder(column: $table.medalId, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$CachedMedalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMedalsTable,
          CachedMedalEntry,
          $$CachedMedalsTableFilterComposer,
          $$CachedMedalsTableOrderingComposer,
          $$CachedMedalsTableAnnotationComposer,
          $$CachedMedalsTableCreateCompanionBuilder,
          $$CachedMedalsTableUpdateCompanionBuilder,
          (
            CachedMedalEntry,
            BaseReferences<_$AppDatabase, $CachedMedalsTable, CachedMedalEntry>,
          ),
          CachedMedalEntry,
          PrefetchHooks Function()
        > {
  $$CachedMedalsTableTableManager(_$AppDatabase db, $CachedMedalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMedalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMedalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMedalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> medalId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMedalsCompanion(
                userId: userId,
                medalId: medalId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String medalId,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedMedalsCompanion.insert(
                userId: userId,
                medalId: medalId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedMedalsTable, CachedMedalEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedMedalsTable,
                    CachedMedalEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedMedalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedMedalsTable,
      CachedMedalEntry,
      $$CachedMedalsTableFilterComposer,
      $$CachedMedalsTableOrderingComposer,
      $$CachedMedalsTableAnnotationComposer,
      $$CachedMedalsTableCreateCompanionBuilder,
      $$CachedMedalsTableUpdateCompanionBuilder,
      (
        CachedMedalEntry,
        BaseReferences<_$AppDatabase, $CachedMedalsTable, CachedMedalEntry>,
      ),
      CachedMedalEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedSkillsTableCreateCompanionBuilder =
    CachedSkillsCompanion Function({
      required String userId,
      required String muscleGroup,
      Value<int> points,
      Value<int> rowid,
    });
typedef $$CachedSkillsTableUpdateCompanionBuilder =
    CachedSkillsCompanion Function({
      Value<String> userId,
      Value<String> muscleGroup,
      Value<int> points,
      Value<int> rowid,
    });

class $$CachedSkillsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSkillsTable> {
  $$CachedSkillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedSkillsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSkillsTable> {
  $$CachedSkillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSkillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSkillsTable> {
  $$CachedSkillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);
}

class $$CachedSkillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSkillsTable,
          CachedSkillEntry,
          $$CachedSkillsTableFilterComposer,
          $$CachedSkillsTableOrderingComposer,
          $$CachedSkillsTableAnnotationComposer,
          $$CachedSkillsTableCreateCompanionBuilder,
          $$CachedSkillsTableUpdateCompanionBuilder,
          (
            CachedSkillEntry,
            BaseReferences<_$AppDatabase, $CachedSkillsTable, CachedSkillEntry>,
          ),
          CachedSkillEntry,
          PrefetchHooks Function()
        > {
  $$CachedSkillsTableTableManager(_$AppDatabase db, $CachedSkillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSkillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSkillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSkillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> muscleGroup = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSkillsCompanion(
                userId: userId,
                muscleGroup: muscleGroup,
                points: points,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String muscleGroup,
                Value<int> points = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSkillsCompanion.insert(
                userId: userId,
                muscleGroup: muscleGroup,
                points: points,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedSkillsTable, CachedSkillEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedSkillsTable,
                    CachedSkillEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedSkillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSkillsTable,
      CachedSkillEntry,
      $$CachedSkillsTableFilterComposer,
      $$CachedSkillsTableOrderingComposer,
      $$CachedSkillsTableAnnotationComposer,
      $$CachedSkillsTableCreateCompanionBuilder,
      $$CachedSkillsTableUpdateCompanionBuilder,
      (
        CachedSkillEntry,
        BaseReferences<_$AppDatabase, $CachedSkillsTable, CachedSkillEntry>,
      ),
      CachedSkillEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedWorkoutsTableCreateCompanionBuilder =
    CachedWorkoutsCompanion Function({
      required String id,
      required String userId,
      required String routineName,
      Value<DateTime?> startedAt,
      required DateTime completedAt,
      required int durationSeconds,
      required double totalVolumeKg,
      required String rawPayload,
      Value<int> rowid,
    });
typedef $$CachedWorkoutsTableUpdateCompanionBuilder =
    CachedWorkoutsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> routineName,
      Value<DateTime?> startedAt,
      Value<DateTime> completedAt,
      Value<int> durationSeconds,
      Value<double> totalVolumeKg,
      Value<String> rawPayload,
      Value<int> rowid,
    });

class $$CachedWorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedWorkoutsTable> {
  $$CachedWorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalVolumeKg => $composableBuilder(
    column: $table.totalVolumeKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedWorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedWorkoutsTable> {
  $$CachedWorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalVolumeKg => $composableBuilder(
    column: $table.totalVolumeKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedWorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedWorkoutsTable> {
  $$CachedWorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalVolumeKg => $composableBuilder(
    column: $table.totalVolumeKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => column,
  );
}

class $$CachedWorkoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedWorkoutsTable,
          CachedWorkoutEntry,
          $$CachedWorkoutsTableFilterComposer,
          $$CachedWorkoutsTableOrderingComposer,
          $$CachedWorkoutsTableAnnotationComposer,
          $$CachedWorkoutsTableCreateCompanionBuilder,
          $$CachedWorkoutsTableUpdateCompanionBuilder,
          (
            CachedWorkoutEntry,
            BaseReferences<
              _$AppDatabase,
              $CachedWorkoutsTable,
              CachedWorkoutEntry
            >,
          ),
          CachedWorkoutEntry,
          PrefetchHooks Function()
        > {
  $$CachedWorkoutsTableTableManager(
    _$AppDatabase db,
    $CachedWorkoutsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedWorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedWorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedWorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> routineName = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> totalVolumeKg = const Value.absent(),
                Value<String> rawPayload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedWorkoutsCompanion(
                id: id,
                userId: userId,
                routineName: routineName,
                startedAt: startedAt,
                completedAt: completedAt,
                durationSeconds: durationSeconds,
                totalVolumeKg: totalVolumeKg,
                rawPayload: rawPayload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String routineName,
                Value<DateTime?> startedAt = const Value.absent(),
                required DateTime completedAt,
                required int durationSeconds,
                required double totalVolumeKg,
                required String rawPayload,
                Value<int> rowid = const Value.absent(),
              }) => CachedWorkoutsCompanion.insert(
                id: id,
                userId: userId,
                routineName: routineName,
                startedAt: startedAt,
                completedAt: completedAt,
                durationSeconds: durationSeconds,
                totalVolumeKg: totalVolumeKg,
                rawPayload: rawPayload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedWorkoutsTable, CachedWorkoutEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedWorkoutsTable,
                    CachedWorkoutEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedWorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedWorkoutsTable,
      CachedWorkoutEntry,
      $$CachedWorkoutsTableFilterComposer,
      $$CachedWorkoutsTableOrderingComposer,
      $$CachedWorkoutsTableAnnotationComposer,
      $$CachedWorkoutsTableCreateCompanionBuilder,
      $$CachedWorkoutsTableUpdateCompanionBuilder,
      (
        CachedWorkoutEntry,
        BaseReferences<_$AppDatabase, $CachedWorkoutsTable, CachedWorkoutEntry>,
      ),
      CachedWorkoutEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedQuestsTableCreateCompanionBuilder =
    CachedQuestsCompanion Function({
      required String id,
      required String userId,
      required String questType,
      required String title,
      required String description,
      required int xpReward,
      Value<String?> targetMetric,
      Value<double?> targetValue,
      Value<String?> exerciseName,
      required DateTime expiresAt,
      Value<DateTime> createdAt,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$CachedQuestsTableUpdateCompanionBuilder =
    CachedQuestsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> questType,
      Value<String> title,
      Value<String> description,
      Value<int> xpReward,
      Value<String?> targetMetric,
      Value<double?> targetValue,
      Value<String?> exerciseName,
      Value<DateTime> expiresAt,
      Value<DateTime> createdAt,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$CachedQuestsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedQuestsTable> {
  $$CachedQuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questType => $composableBuilder(
    column: $table.questType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetMetric => $composableBuilder(
    column: $table.targetMetric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedQuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedQuestsTable> {
  $$CachedQuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questType => $composableBuilder(
    column: $table.questType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetMetric => $composableBuilder(
    column: $table.targetMetric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedQuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedQuestsTable> {
  $$CachedQuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get questType =>
      $composableBuilder(column: $table.questType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<String> get targetMetric => $composableBuilder(
    column: $table.targetMetric,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$CachedQuestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedQuestsTable,
          CachedQuestEntry,
          $$CachedQuestsTableFilterComposer,
          $$CachedQuestsTableOrderingComposer,
          $$CachedQuestsTableAnnotationComposer,
          $$CachedQuestsTableCreateCompanionBuilder,
          $$CachedQuestsTableUpdateCompanionBuilder,
          (
            CachedQuestEntry,
            BaseReferences<_$AppDatabase, $CachedQuestsTable, CachedQuestEntry>,
          ),
          CachedQuestEntry,
          PrefetchHooks Function()
        > {
  $$CachedQuestsTableTableManager(_$AppDatabase db, $CachedQuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedQuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedQuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedQuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> questType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<String?> targetMetric = const Value.absent(),
                Value<double?> targetValue = const Value.absent(),
                Value<String?> exerciseName = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedQuestsCompanion(
                id: id,
                userId: userId,
                questType: questType,
                title: title,
                description: description,
                xpReward: xpReward,
                targetMetric: targetMetric,
                targetValue: targetValue,
                exerciseName: exerciseName,
                expiresAt: expiresAt,
                createdAt: createdAt,
                isCompleted: isCompleted,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String questType,
                required String title,
                required String description,
                required int xpReward,
                Value<String?> targetMetric = const Value.absent(),
                Value<double?> targetValue = const Value.absent(),
                Value<String?> exerciseName = const Value.absent(),
                required DateTime expiresAt,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedQuestsCompanion.insert(
                id: id,
                userId: userId,
                questType: questType,
                title: title,
                description: description,
                xpReward: xpReward,
                targetMetric: targetMetric,
                targetValue: targetValue,
                exerciseName: exerciseName,
                expiresAt: expiresAt,
                createdAt: createdAt,
                isCompleted: isCompleted,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedQuestsTable, CachedQuestEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedQuestsTable,
                    CachedQuestEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedQuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedQuestsTable,
      CachedQuestEntry,
      $$CachedQuestsTableFilterComposer,
      $$CachedQuestsTableOrderingComposer,
      $$CachedQuestsTableAnnotationComposer,
      $$CachedQuestsTableCreateCompanionBuilder,
      $$CachedQuestsTableUpdateCompanionBuilder,
      (
        CachedQuestEntry,
        BaseReferences<_$AppDatabase, $CachedQuestsTable, CachedQuestEntry>,
      ),
      CachedQuestEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedProfilesTableTableManager get cachedProfiles =>
      $$CachedProfilesTableTableManager(_db, _db.cachedProfiles);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$CachedMedalsTableTableManager get cachedMedals =>
      $$CachedMedalsTableTableManager(_db, _db.cachedMedals);
  $$CachedSkillsTableTableManager get cachedSkills =>
      $$CachedSkillsTableTableManager(_db, _db.cachedSkills);
  $$CachedWorkoutsTableTableManager get cachedWorkouts =>
      $$CachedWorkoutsTableTableManager(_db, _db.cachedWorkouts);
  $$CachedQuestsTableTableManager get cachedQuests =>
      $$CachedQuestsTableTableManager(_db, _db.cachedQuests);
}
