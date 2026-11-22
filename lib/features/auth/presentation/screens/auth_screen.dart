import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stryde/core/theme/app_colors.dart';
import 'package:stryde/core/theme/app_spacing.dart';
import 'package:stryde/features/auth/presentation/providers/auth_provider.dart';

/// Red used exclusively for authentication error messages. Everything else on
/// this screen stays strictly monochrome.
const Color _authErrorRed = Color(0xFFE45757);

const double _authMaxWidth = 410;
const double _authButtonHeight = 54;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _usernameFocus = FocusNode();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _confirmationNoticeShown = false;

  String? _emailError;
  String? _passwordError;
  String? _usernameError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  void _selectMode(bool isSignUp) {
    if (_isLoading || _isSignUp == isSignUp) return;
    ref.read(authProvider.notifier).clearError();
    setState(() {
      _isSignUp = isSignUp;
      _confirmationNoticeShown = false;
      _emailError = null;
      _passwordError = null;
      _usernameError = null;
    });
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    ref.read(authProvider.notifier).clearError();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    final emailError = email.isEmpty || !email.contains('@')
        ? 'Enter a valid email address'
        : null;
    final passwordError = password.isEmpty ? 'Enter a password' : null;
    final usernameError = _isSignUp && username.isEmpty
        ? 'Choose a username'
        : null;

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _usernameError = usernameError;
      _isLoading =
          emailError == null && passwordError == null && usernameError == null;
      if (_isLoading) _confirmationNoticeShown = false;
    });

    if (!_isLoading) return;

    if (_isSignUp) {
      final succeeded = await ref
          .read(authProvider.notifier)
          .signUp(email: email, password: password, username: username);
      if (!mounted) return;
      // When email confirmations are enabled there is no session yet.
      if (succeeded &&
          ref.read(supabaseProvider)?.auth.currentSession == null &&
          !_confirmationNoticeShown) {
        setState(() {
          _confirmationNoticeShown = true;
          _isSignUp = false;
          _passwordController.clear();
        });
      }
    } else {
      await ref
          .read(authProvider.notifier)
          .signIn(email: email, password: password);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final serverError = authState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minimumHeight =
                (constraints.maxHeight - (AppSpacing.space24 * 2)).clamp(
                  0.0,
                  double.infinity,
                );

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpacing.space24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minimumHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _authMaxWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _BrandMark(isSignUp: _isSignUp),
                        const SizedBox(height: AppSpacing.space40),
                        _ModeSelector(
                          isSignUp: _isSignUp,
                          onLogIn: () => _selectMode(false),
                          onCreateAccount: () => _selectMode(true),
                        ),
                        const SizedBox(height: AppSpacing.space32),
                        Text(
                          'Email',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        TextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            ref.read(authProvider.notifier).clearError();
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          onSubmitted: (_) => FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocus),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          decoration: _inputDecoration(
                            'hello@stryde.app',
                            errorText: _emailError,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space20),
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          obscureText: true,
                          autofillHints: <String>[
                            _isSignUp
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: _isSignUp
                              ? TextInputAction.next
                              : TextInputAction.go,
                          onChanged: (_) {
                            ref.read(authProvider.notifier).clearError();
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          onSubmitted: (_) {
                            if (_isSignUp) {
                              FocusScope.of(
                                context,
                              ).requestFocus(_usernameFocus);
                            } else {
                              _submit();
                            }
                          },
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          decoration: _inputDecoration(
                            '••••••••',
                            errorText: _passwordError,
                          ),
                        ),
                        if (_isSignUp) ...[
                          const SizedBox(height: AppSpacing.space24),
                          Text(
                            'Username',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          TextField(
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            autofillHints: const <String>[
                              AutofillHints.username,
                            ],
                            autocorrect: false,
                            textInputAction: TextInputAction.go,
                            onChanged: (_) {
                              ref.read(authProvider.notifier).clearError();
                              if (_usernameError != null) {
                                setState(() => _usernameError = null);
                              }
                            },
                            onSubmitted: (_) => _submit(),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: _inputDecoration(
                              'stryder',
                              errorText: _usernameError,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.space24),
                        if (serverError != null) ...[
                          Text(
                            serverError,
                            style: _errorStyle.copyWith(height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.space16),
                        ],
                        SizedBox(
                          height: _authButtonHeight,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Create account' : 'Login',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.space6,
                          runSpacing: AppSpacing.space4,
                          children: <Widget>[
                            Text(
                              _isSignUp
                                  ? 'Already have an account?'
                                  : "Don't have an account?",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                            GestureDetector(
                              onTap: () => _selectMode(!_isSignUp),
                              child: Text(
                                _isSignUp ? 'Login' : 'Sign up',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (_confirmationNoticeShown) ...[
                          const SizedBox(height: AppSpacing.space20),
                          Text(
                            'Check your email to confirm your account, then log in.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, {String? errorText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.textMuted,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      errorText: errorText,
      errorStyle: _errorStyle,
      errorMaxLines: 3,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: 17,
      ),
      isCollapsed: true,
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
        borderSide: BorderSide(color: AppColors.textPrimary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _authErrorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _authErrorRed),
      ),
    );
  }

  TextStyle get _errorStyle => TextStyle(
    color: _authErrorRed,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.isSignUp});

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.fitness_center_rounded,
            size: 30,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        Text('Stryde', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: AppSpacing.space6),
        Text(
          isSignUp ? 'Create your account' : 'Sign in to your account',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.isSignUp,
    required this.onLogIn,
    required this.onCreateAccount,
  });

  final bool isSignUp;
  final VoidCallback onLogIn;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ModeButton(
            selected: !isSignUp,
            label: 'Login',
            onTap: onLogIn,
          ),
        ),
        Container(width: 1, height: 22, color: AppColors.border),
        Expanded(
          child: _ModeButton(
            selected: isSignUp,
            label: 'Sign up',
            onTap: onCreateAccount,
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.onPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
