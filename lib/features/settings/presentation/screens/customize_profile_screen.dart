import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/core/widgets/app_surface_card.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';
import 'package:stryde/features/profile/presentation/providers/user_profile_provider.dart';

class CustomizeProfileScreen extends ConsumerStatefulWidget {
  const CustomizeProfileScreen({super.key});

  @override
  ConsumerState<CustomizeProfileScreen> createState() =>
      _CustomizeProfileScreenState();
}

class _CustomizeProfileScreenState
    extends ConsumerState<CustomizeProfileScreen> {
  late final TextEditingController _nameController;
  final _focusNode = FocusNode();
  bool _isUploadingImage = false;
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(
      text: profile.displayName ?? profile.username ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() {
    return _handlePickAndUploadAvatar();
  }

  Future<void> _handlePickAndUploadAvatar() async {
    final user = ref.read(currentUserProvider);
    final supabase = ref.read(supabaseProvider);
    if (user == null || supabase == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final bytes = await pickedFile.readAsBytes();
      final extension = pickedFile.name.split('.').last;
      final fileName =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

      await supabase.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$extension',
              upsert: true,
            ),
          );

      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      await ref.read(userProfileProvider.notifier).setAvatarUrl(publicUrl);

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Profile picture updated'),
              backgroundColor: AppColors.surfaceVariant,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              backgroundColor: AppColors.surfaceVariant,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _saveDisplayName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSavingName = true);
    try {
      await ref.read(userProfileProvider.notifier).setDisplayName(name);
      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Display name saved'),
              backgroundColor: AppColors.surfaceVariant,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingName = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final avatarUrl = profile.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.trim().isNotEmpty;

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
          'Customize Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space24,
            vertical: AppSpacing.space16,
          ),
          children: <Widget>[
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickAndUploadAvatar,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderStrong,
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      child: _isUploadingImage
                          ? SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : hasAvatar
                              ? Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  width: 104,
                                  height: 104,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    Icons.person_rounded,
                                    size: 52,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : Icon(
                                  Icons.person_rounded,
                                  size: 52,
                                  color: AppColors.onPrimary,
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _pickAndUploadAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.space8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            Center(
              child: TextButton.icon(
                key: const ValueKey<String>('change-avatar-button'),
                onPressed: _isUploadingImage ? null : _pickAndUploadAvatar,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: Text(
                  _isUploadingImage ? 'Uploading...' : 'Choose from Gallery',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            Text(
              'PROFILE DETAILS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
            ),
            const SizedBox(height: AppSpacing.space12),
            AppSurfaceCard(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Display Name',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This name will be displayed on the Home greeting and your Profile.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  TextField(
                    key: const ValueKey<String>('customize-profile-display-name-input'),
                    controller: _nameController,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveDisplayName(),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space16,
                        vertical: AppSpacing.space16,
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
                  const SizedBox(height: AppSpacing.space20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      key: const ValueKey<String>('customize-profile-save-button'),
                      onPressed: _isSavingName ? null : _saveDisplayName,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSavingName
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
