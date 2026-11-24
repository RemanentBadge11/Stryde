import 'package:stryde/features/progression/domain/entities/rank.dart';

class SocialProfile {
  const SocialProfile({
    required this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.level = 1,
    this.totalXp = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.isCurrentUser = false,
  });

  final String id;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final int level;
  final int totalXp;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isCurrentUser;

  String get effectiveName {
    final u = username?.trim();
    if (u != null && u.isNotEmpty) return u;
    final d = displayName?.trim();
    if (d != null && d.isNotEmpty) return d;
    return 'Athlete';
  }

  String get handle {
    final u = username?.trim();
    if (u != null && u.isNotEmpty) return '@$u';
    return '@user';
  }

  String get rankTitle => Ranks.forLevel(level).name;

  String get rankSvgPath => RankAssetResolver.getSvgAssetPath(rankTitle);

  SocialProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    int? level,
    int? totalXp,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    bool? isCurrentUser,
  }) {
    return SocialProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      totalXp: totalXp ?? this.totalXp,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  factory SocialProfile.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
    bool isFollowing = false,
    int followersCount = 0,
    int followingCount = 0,
  }) {
    final id = json['id']?.toString() ?? '';
    return SocialProfile(
      id: id,
      username: json['username']?.toString(),
      displayName: json['display_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      level: json['level'] as int? ?? 1,
      totalXp: json['total_xp'] as int? ?? json['xp'] as int? ?? 0,
      followersCount: followersCount,
      followingCount: followingCount,
      isFollowing: isFollowing,
      isCurrentUser: currentUserId != null && currentUserId == id,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    if (username != null) 'username': username,
    if (displayName != null) 'display_name': displayName,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    'level': level,
    'total_xp': totalXp,
    'followers_count': followersCount,
    'following_count': followingCount,
    'is_following': isFollowing,
  };
}
