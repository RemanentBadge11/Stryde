import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/empty_state_card.dart';
import 'package:stryde/core/widgets/loading_state_card.dart';
import 'package:stryde/features/social/domain/entities/social_post.dart';
import 'package:stryde/features/social/presentation/providers/social_providers.dart';
import 'package:stryde/features/social/presentation/widgets/social_rank_up_card.dart';
import 'package:stryde/features/social/presentation/widgets/social_workout_card.dart';

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(socialFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(socialFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space24,
                AppSpacing.space16,
                AppSpacing.space16,
                AppSpacing.space8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Social',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  IconButton(
                    key: const ValueKey<String>('social-search-button'),
                    icon: const Icon(Icons.search_rounded, size: 26),
                    color: AppColors.textPrimary,
                    tooltip: 'Find athletes',
                    onPressed: () => context.push('/social/search'),
                  ),
                ],
              ),
            ),

            // Feed Content
            Expanded(child: _buildBody(context, feedState)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SocialFeedState state) {
    // 1. Offline State
    if (state.isOffline && state.posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            EmptyStateCard(
              icon: Icons.wifi_off_rounded,
              title: "You're offline",
              message:
                  'Social requires an internet connection. Connect to the internet to view athlete activity.',
            ),
            const SizedBox(height: AppSpacing.space16),
            FilledButton.icon(
              onPressed: () => ref.read(socialFeedProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Loading State
    if (state.isLoading && state.posts.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.space16),
        itemBuilder: (context, index) => const LoadingStateCard(height: 180),
      );
    }

    // 3. Error State
    if (state.errorMessage != null && state.posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            EmptyStateCard(
              icon: Icons.error_outline_rounded,
              title: 'Could not load feed',
              message: state.errorMessage!,
            ),
            const SizedBox(height: AppSpacing.space16),
            FilledButton.icon(
              onPressed: () => ref.read(socialFeedProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    // 4. Empty State
    if (state.posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(socialFeedProvider.notifier).refresh(),
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(AppSpacing.space24),
          children: <Widget>[
            const SizedBox(height: 60),
            EmptyStateCard(
              icon: Icons.people_outline_rounded,
              title: 'No activity yet',
              message:
                  'Follow athletes to see their completed workouts and rank promotions here.',
            ),
            const SizedBox(height: AppSpacing.space20),
            Center(
              child: FilledButton.icon(
                key: const ValueKey<String>('discover-athletes-button'),
                onPressed: () => context.push('/social/search'),
                icon: const Icon(Icons.person_search_rounded, size: 18),
                label: const Text('Discover Athletes'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space20,
                    vertical: AppSpacing.space12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 5. Active Feed List
    return RefreshIndicator(
      onRefresh: () => ref.read(socialFeedProvider.notifier).refresh(),
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space24,
          AppSpacing.space8,
          AppSpacing.space24,
          AppSpacing.space32,
        ),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.space16),
        itemBuilder: (context, index) {
          if (index == state.posts.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.space16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            );
          }

          final post = state.posts[index];
          if (post.type == SocialPostType.workout) {
            return SocialWorkoutCard(post: post);
          } else {
            return SocialRankUpCard(post: post);
          }
        },
      ),
    );
  }
}
