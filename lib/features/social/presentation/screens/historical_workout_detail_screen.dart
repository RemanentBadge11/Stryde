import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/theme/app_typography.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/core/widgets/empty_state_card.dart';
import 'package:stryde/core/widgets/loading_state_card.dart';
import 'package:stryde/features/exercises/presentation/providers/exercise_library_provider.dart';
import 'package:stryde/features/exercises/presentation/widgets/exercise_image.dart';
import 'package:stryde/features/routines/domain/entities/exercise.dart';
import 'package:stryde/features/routines/domain/entities/workout_routine.dart';
import 'package:stryde/features/routines/presentation/providers/custom_routines_provider.dart';
import 'package:stryde/features/social/data/social_repository.dart';
import 'package:stryde/features/social/domain/entities/social_post.dart';
import 'package:stryde/features/social/presentation/widgets/social_author_header.dart';
import 'package:stryde/features/workout_history/domain/entities/completed_workout.dart';
import 'package:stryde/features/workout_history/presentation/workout_formatters.dart';

final socialPostDetailProvider = FutureProvider.autoDispose
    .family<SocialPost?, String>((ref, postId) async {
      final repo = ref.watch(socialRepositoryProvider);
      return repo.getPostById(postId);
    });

class HistoricalWorkoutDetailScreen extends ConsumerStatefulWidget {
  const HistoricalWorkoutDetailScreen({
    required this.postId,
    this.initialPost,
    super.key,
  });

  final String postId;
  final SocialPost? initialPost;

  @override
  ConsumerState<HistoricalWorkoutDetailScreen> createState() =>
      _HistoricalWorkoutDetailScreenState();
}

class _HistoricalWorkoutDetailScreenState
    extends ConsumerState<HistoricalWorkoutDetailScreen> {
  bool _isSavingRoutine = false;
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    final asyncPost = ref.watch(socialPostDetailProvider(widget.postId));
    final post = asyncPost.value ?? widget.initialPost;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Workout Details',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: post == null
            ? asyncPost.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.space24),
                  child: LoadingStateCard(height: 240),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.space24),
                  child: EmptyStateCard(
                    icon: Icons.error_outline_rounded,
                    title: 'Workout unavailable',
                    message: 'Could not load workout: $e',
                  ),
                ),
                data: (_) => const Padding(
                  padding: EdgeInsets.all(AppSpacing.space24),
                  child: EmptyStateCard(
                    icon: Icons.search_off_rounded,
                    title: 'Workout not found',
                    message:
                        'This historical workout post is no longer available.',
                  ),
                ),
              )
            : _buildContent(context, post),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SocialPost post) {
    final workout = post.workoutData;
    if (workout == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.space24),
        child: EmptyStateCard(
          icon: Icons.fitness_center_rounded,
          title: 'No workout data',
          message: 'This post does not contain workout data.',
        ),
      );
    }

    final snapshot = workout.snapshot;
    final exercises = snapshot.exercises;
    final prSet = workout.prExercises.toSet();

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space24,
              AppSpacing.space16,
              AppSpacing.space24,
              AppSpacing.space24,
            ),
            children: <Widget>[
              // Author Header
              SocialAuthorHeader(
                author: post.author,
                subtitle: Text(
                  'Completed ${formatWorkoutTimestamp(workout.completedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space20),

              // Workout Routine Name
              Text(
                workout.routineName,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.space16),

              // Summary Metrics
              Row(
                children: <Widget>[
                  Expanded(
                    child: _DetailMetric(
                      value: _formatDuration(workout.duration),
                      label: 'Duration',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  Expanded(
                    child: _DetailMetric(
                      value: '${workout.totalSets}',
                      label: 'Sets',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  Expanded(
                    child: _DetailMetric(
                      value: '${workout.totalReps}',
                      label: 'Reps',
                    ),
                  ),
                  if (workout.totalVolumeKg > 0) ...<Widget>[
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: _DetailMetric(
                        value: workout.totalVolumeKg.toStringAsFixed(0),
                        label: 'kg volume',
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.space28),

              // Exercise List Section Header
              Text(
                'Exercises (${exercises.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.space12),

              // Exercise Cards
              for (var i = 0; i < exercises.length; i++) ...<Widget>[
                _HistoricalExerciseCard(
                  exercise: exercises[i],
                  hasPr: prSet.contains(exercises[i].exerciseName),
                ),
                if (i != exercises.length - 1)
                  const SizedBox(height: AppSpacing.space16),
              ],
            ],
          ),
        ),

        // Bottom Action Bar: "Save Workout Routine"
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space24,
            AppSpacing.space12,
            AppSpacing.space24,
            AppSpacing.space24,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              key: const ValueKey<String>('save-workout-routine-button'),
              onPressed: (_isSavingRoutine || _isSaved)
                  ? null
                  : () => _handleSaveRoutine(post, snapshot),
              style: FilledButton.styleFrom(
                backgroundColor: _isSaved
                    ? AppColors.surfaceVariant
                    : AppColors.primary,
                foregroundColor: _isSaved
                    ? AppColors.textSecondary
                    : AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isSavingRoutine
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : Icon(
                      _isSaved
                          ? Icons.check_rounded
                          : Icons.bookmark_add_rounded,
                      size: 20,
                    ),
              label: Text(
                _isSaved
                    ? 'Routine Saved'
                    : _isSavingRoutine
                    ? 'Saving Routine...'
                    : 'Save Workout Routine',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSaveRoutine(
    SocialPost post,
    CompletedWorkout snapshot,
  ) async {
    if (_isSavingRoutine || _isSaved) return;

    setState(() => _isSavingRoutine = true);

    try {
      final library =
          ref.read(exerciseLibraryProvider).value ?? const <Exercise>[];

      final routineExercises = <RoutineExercise>[];
      for (final ex in snapshot.exercises) {
        // Find existing exercise definition in library or create fallback
        Exercise? def;
        for (final item in library) {
          if (item.id == ex.exerciseId ||
              item.name.toLowerCase() == ex.exerciseName.toLowerCase()) {
            def = item;
            break;
          }
        }

        final exercise =
            def ??
            Exercise(
              id: ex.exerciseId.isNotEmpty
                  ? ex.exerciseId
                  : ex.exerciseName.toLowerCase().replaceAll(' ', '-'),
              name: ex.exerciseName,
              primaryMuscle: 'Other',
              equipment: 'Other',
              type: ex.exerciseType,
              imageUrl: 'asset:assets/images/generic.png',
            );

        final targetSetDetails = <RoutineSetTarget>[
          for (final s in ex.sets)
            RoutineSetTarget(
              weightKg: s.weightKg > 0 ? s.weightKg : null,
              reps: s.reps > 0 ? s.reps : null,
              durationSeconds: s.durationSeconds,
              distance: s.distance,
              incline: s.incline,
              steps: s.steps,
              resistanceLevel: s.resistanceLevel,
            ),
        ];

        final targetSets = ex.sets.isNotEmpty ? ex.sets.length : 1;
        final targetReps = ex.sets.isNotEmpty && ex.sets.first.reps > 0
            ? ex.sets.first.reps
            : (exercise.isCardioExercise ? null : 10);

        routineExercises.add(
          RoutineExercise(
            exercise: exercise,
            targetSets: targetSets,
            targetReps: targetReps,
            targetSetDetails: targetSetDetails,
          ),
        );
      }

      final authorHandle = post.author.username ?? post.author.effectiveName;
      final newRoutine = WorkoutRoutine(
        id: 'saved-${DateTime.now().millisecondsSinceEpoch}-${snapshot.id}',
        name: snapshot.routineName,
        focus: 'Imported Routine',
        estimatedMinutes: snapshot.duration.inMinutes > 0
            ? snapshot.duration.inMinutes
            : 45,
        exercises: routineExercises,
        isCustom: true,
        savedFromUsername: authorHandle,
      );

      // Add to saving user's existing workout routines
      ref.read(customRoutinesProvider.notifier).addRoutine(newRoutine);

      if (mounted) {
        setState(() {
          _isSaved = true;
          _isSavingRoutine = false;
        });

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Routine "${newRoutine.name}" saved to Train!'),
              backgroundColor: AppColors.surfaceVariant,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingRoutine = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save routine: $e'),
            backgroundColor: AppColors.surfaceVariant,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${duration.inMinutes}m';
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space12,
      ),
      child: Column(
        children: <Widget>[
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFeatures: AppTypography.tabularFontFeatures,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          FittedBox(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoricalExerciseCard extends ConsumerWidget {
  const _HistoricalExerciseCard({required this.exercise, this.hasPr = false});

  final CompletedWorkoutExercise exercise;
  final bool hasPr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library =
        ref.watch(exerciseLibraryProvider).value ?? const <Exercise>[];

    Exercise? def;
    for (final item in library) {
      if (item.id == exercise.exerciseId ||
          item.name.toLowerCase() == exercise.exerciseName.toLowerCase()) {
        def = item;
        break;
      }
    }

    final localImage = def?.localImage;
    final imageUrl = def?.imageUrl ?? 'asset:assets/images/generic.png';

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Exercise Header with Illustration & PR badge
          Row(
            children: <Widget>[
              ExerciseImage(
                imageUrl: imageUrl,
                localImage: localImage,
                semanticLabel: exercise.exerciseName,
                width: 48,
                height: 48,
                borderRadius: 10,
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      exercise.exerciseName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exercise.sets.length} ${exercise.sets.length == 1 ? 'SET' : 'SETS'}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasPr)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space12),
          const Divider(),
          const SizedBox(height: AppSpacing.space4),

          // Sets Breakdown
          for (final set in exercise.sets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 48,
                    child: Text(
                      'SET ${set.setNumber}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatSetValues(exercise.exerciseType, set),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFeatures: AppTypography.tabularFontFeatures,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatSetValues(String type, CompletedWorkoutSet set) {
    final parts = <String>[];
    if (set.weightKg > 0) {
      parts.add(
        '${set.weightKg == set.weightKg.roundToDouble() ? set.weightKg.toInt() : set.weightKg.toStringAsFixed(1)} kg',
      );
    }
    if (set.reps > 0) {
      parts.add('${set.reps} reps');
    }
    if (set.durationSeconds != null && set.durationSeconds! > 0) {
      final m = set.durationSeconds! ~/ 60;
      final s = set.durationSeconds! % 60;
      parts.add('${m}m ${s}s');
    }
    if (set.distance != null && set.distance! > 0) {
      parts.add('${set.distance!.toStringAsFixed(2)} km');
    }
    if (set.incline != null && set.incline! > 0) {
      parts.add('${set.incline}% incl');
    }
    if (set.resistanceLevel != null && set.resistanceLevel!.isNotEmpty) {
      parts.add('Lvl ${set.resistanceLevel}');
    }
    if (set.steps != null && set.steps! > 0) {
      parts.add('${set.steps} steps');
    }
    return parts.isEmpty ? 'Completed' : parts.join(' × ');
  }
}
