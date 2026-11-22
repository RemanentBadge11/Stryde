import 'package:material_ui/material_ui.dart';

class Medal {
  const Medal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

const List<Medal> kStaticMedals = [
  Medal(
    id: 'first_pr',
    title: 'First PR',
    description: 'Set your first Personal Record',
    icon: Icons.military_tech_rounded,
  ),
  Medal(
    id: 'five_prs',
    title: '5 PRs',
    description: 'Achieve 5 Personal Records',
    icon: Icons.emoji_events_rounded,
  ),
  Medal(
    id: 'level_5',
    title: 'Level 5',
    description: 'Reach Level 5',
    icon: Icons.stars_rounded,
  ),
  Medal(
    id: 'level_10',
    title: 'Level 10',
    description: 'Reach Level 10',
    icon: Icons.workspace_premium_rounded,
  ),
  Medal(
    id: 'streak_7',
    title: '7 Day Streak',
    description: 'Maintain a 7-day workout streak',
    icon: Icons.local_fire_department_rounded,
  ),
  Medal(
    id: 'streak_30',
    title: '30 Day Streak',
    description: 'Maintain a 30-day workout streak',
    icon: Icons.whatshot_rounded,
  ),
];
