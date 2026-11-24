import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/empty_state_card.dart';
import 'package:stryde/core/widgets/loading_state_card.dart';
import 'package:stryde/features/social/presentation/providers/social_providers.dart';
import 'package:stryde/features/social/presentation/widgets/user_list_tile.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(userSearchProvider);

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
          'Find Athletes',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space24,
                vertical: AppSpacing.space12,
              ),
              child: TextField(
                key: const ValueKey<String>('athlete-search-input'),
                controller: _controller,
                autofocus: true,
                onChanged: (val) =>
                    ref.read(userSearchProvider.notifier).onQueryChanged(val),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by username...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _controller.clear();
                            ref
                                .read(userSearchProvider.notifier)
                                .onQueryChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),

            // Results List
            Expanded(child: _buildResults(context, searchState)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, UserSearchState state) {
    if (state.isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.space24),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.space12),
        itemBuilder: (context, index) => const LoadingStateCard(height: 72),
      );
    }

    if (state.query.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            EmptyStateCard(
              icon: Icons.person_search_rounded,
              title: 'Search athletes',
              message:
                  'Type a username to discover athletes and their activity.',
            ),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            EmptyStateCard(
              icon: Icons.search_off_rounded,
              title: 'No athletes found',
              message: 'No user matches "${state.query.trim()}".',
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space24,
        AppSpacing.space8,
        AppSpacing.space24,
        AppSpacing.space32,
      ),
      itemCount: state.results.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.space12),
      itemBuilder: (context, index) {
        final profile = state.results[index];
        return UserListTile(
          profile: profile,
          onToggleFollow: () =>
              ref.read(userSearchProvider.notifier).toggleFollowUser(profile),
        );
      },
    );
  }
}
