import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/theme/app_typography.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/core/widgets/loading_state_card.dart';
import 'package:stryde/core/widgets/section_header.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/profile/presentation/providers/profile_goals_provider.dart';
import 'package:stryde/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:stryde/features/progression/presentation/providers/user_progression_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(profileGoalsProvider);
    final progression = ref.watch(userProgressionProvider);
    final progressionLoading = ref.watch(userProgressionLoadingProvider);
    final notifier = ref.read(profileGoalsProvider.notifier);
    final userProfile = ref.watch(userProfileProvider);
    final displayName = userProfile.effectiveName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space24,
            AppSpacing.space32,
          ),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                IconButton(
                  key: const ValueKey<String>('profile-settings-button'),
                  icon: const Icon(Icons.settings_outlined, size: 26),
                  color: AppColors.textPrimary,
                  tooltip: 'Settings',
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Set the targets that shape your habits.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space24),
            if (progressionLoading)
              const LoadingStateCard(height: 112)
            else
              _IdentityCard(
                name: displayName,
                level: progression.currentLevel,
                rank: progression.rankTitle,
                skillPoints: progression.skillPoints,
                avatarUrl: userProfile.avatarUrl,
              ),
            const SizedBox(height: AppSpacing.space16),
            AppSurfaceCard(
              onTap: () => context.push('/medals'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space20,
                vertical: AppSpacing.space16,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Medals',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Milestones & Achievements',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            SectionHeader(
              title: 'Goals',
              subtitle: 'These values feed your Habits on Home.',
            ),
            const SizedBox(height: AppSpacing.space12),
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                children: <Widget>[
                  _GoalStepper(
                    icon: Icons.directions_walk_rounded,
                    label: 'Daily Steps',
                    value: _formatNumber(goals.steps),
                    rawValue: '${goals.steps}',
                    unit: 'steps',
                    isDecimal: false,
                    onDecrease: () => notifier.adjustSteps(
                      -ProfileGoalsNotifier.stepIncrement,
                    ),
                    onIncrease: () => notifier.adjustSteps(
                      ProfileGoalsNotifier.stepIncrement,
                    ),
                    onManualSubmit: (text) {
                      final clean = text
                          .replaceAll(',', '')
                          .replaceAll(' ', '')
                          .trim();
                      final parsed = int.tryParse(clean);
                      if (parsed != null && parsed > 0) {
                        notifier.setGoals(steps: parsed);
                      }
                    },
                  ),
                  const Divider(),
                  _GoalStepper(
                    icon: Icons.water_drop_outlined,
                    label: 'Daily Water',
                    value: _formatWater(goals.waterLiters),
                    rawValue: _formatWater(goals.waterLiters),
                    unit: 'liters',
                    isDecimal: true,
                    onDecrease: () => notifier.adjustWater(
                      -ProfileGoalsNotifier.waterIncrement,
                    ),
                    onIncrease: () => notifier.adjustWater(
                      ProfileGoalsNotifier.waterIncrement,
                    ),
                    onManualSubmit: (text) {
                      final clean = text
                          .replaceAll(',', '.')
                          .replaceAll(' ', '')
                          .replaceAll(RegExp(r'[Ll]'), '')
                          .trim();
                      final parsed = double.tryParse(clean);
                      if (parsed != null && parsed > 0) {
                        notifier.setGoals(water: parsed);
                      }
                    },
                  ),
                  const Divider(),
                  _GoalStepper(
                    icon: Icons.restaurant_outlined,
                    label: 'Daily Protein',
                    value: '${goals.proteinGrams}',
                    rawValue: '${goals.proteinGrams}',
                    unit: 'grams',
                    isDecimal: false,
                    onDecrease: () => notifier.adjustProtein(
                      -ProfileGoalsNotifier.proteinIncrement,
                    ),
                    onIncrease: () => notifier.adjustProtein(
                      ProfileGoalsNotifier.proteinIncrement,
                    ),
                    onManualSubmit: (text) {
                      final clean = text
                          .replaceAll(RegExp(r'[Gg]'), '')
                          .replaceAll(' ', '')
                          .trim();
                      final parsed = int.tryParse(clean);
                      if (parsed != null && parsed > 0) {
                        notifier.setGoals(protein: parsed);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            AppSurfaceCard(
              radius: 16,
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Text(
                      'XP, streaks, skills, workout history, and daily goals sync to your account.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                key: const ValueKey<String>('profile-logout-button'),
                onPressed: () async {
                  final signedOut = await ref
                      .read(authProvider.notifier)
                      .signOut();
                  if (!context.mounted || signedOut) return;
                  final message = ref.read(authProvider).errorMessage;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(message ?? 'Unable to log out.'),
                        backgroundColor: AppColors.surfaceVariant,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: AppSpacing.space12),
                    Text('Logout'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.level,
    required this.rank,
    required this.skillPoints,
    this.avatarUrl,
  });

  final String name;
  final int level;
  final String rank;
  final int skillPoints;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderStrong.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: hasAvatar
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    width: 64,
                    height: 64,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    size: 34,
                    color: AppColors.onPrimary,
                  ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.space4),
                Text(
                  'Level $level · $rank',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.space8),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.bolt_rounded,
                      size: 15,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      skillPoints == 1
                          ? '1 skill point'
                          : '$skillPoints skill points',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalStepper extends StatefulWidget {
  const _GoalStepper({
    required this.icon,
    required this.label,
    required this.value,
    required this.rawValue,
    required this.unit,
    required this.isDecimal,
    required this.onDecrease,
    required this.onIncrease,
    required this.onManualSubmit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String rawValue;
  final String unit;
  final bool isDecimal;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<String> onManualSubmit;

  @override
  State<_GoalStepper> createState() => _GoalStepperState();
}

class _GoalStepperState extends State<_GoalStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.rawValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _GoalStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.rawValue != widget.rawValue) {
      _controller.text = widget.rawValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onManualSubmit(text);
    }
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(widget.icon, size: 19, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.value} ${widget.unit}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontFeatures: AppTypography.tabularFontFeatures,
                  ),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.remove_rounded,
            tooltip: 'Decrease ${widget.label}',
            onPressed: widget.onDecrease,
          ),
          const SizedBox(width: AppSpacing.space6),
          _StepButton(
            icon: Icons.add_rounded,
            tooltip: 'Increase ${widget.label}',
            onPressed: widget.onIncrease,
          ),
          const SizedBox(width: AppSpacing.space8),
          SizedBox(
            width: 68,
            height: 38,
            child: TextField(
              key: ValueKey<String>('goal-input-${widget.label}'),
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.isDecimal,
              ),
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: AppTypography.tabularFontFeatures,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        minimumSize: const Size(38, 38),
        maximumSize: const Size(38, 38),
        backgroundColor: AppColors.surfaceVariant,
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.border),
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

String _formatNumber(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _formatWater(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);
