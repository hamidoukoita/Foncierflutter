import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(
          _phoneCtrl.text,
          _passwordCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      final user = ref.read(authProvider).user;
      if (user?.isAgent == true || user?.isSociete == true) {
        context.go('/agent/dashboard');
      } else {
        context.go('/prospect/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),

                // Logo Foncier+
                Center(
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 210,
                    fit: BoxFit.contain,
                    semanticsLabel: 'Logo Foncier Plus',
                    placeholderBuilder: (context) => const SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Titre
                Text(
                  'Connectez-vous à votre espace',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Numéro de téléphone
                AppTextField(
                  label: 'Numéro de téléphone',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  hintText: '76 12 34 56',
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSpacing.gapSm,
                      const Text('🇲🇱', style: TextStyle(fontSize: 15)),
                      AppSpacing.gapSm,
                      Text(
                        '+223',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlueAnthracite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                        ),
                        color: AppColors.borderLight,
                      ),
                    ],
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Numéro obligatoire'
                      : null,
                ),

                const SizedBox(height: AppSpacing.md),

                // Mot de passe
                AppTextField(
                  label: 'Mot de passe',
                  controller: _passwordCtrl,
                  isPassword: true,
                  hintText: 'Votre mot de passe',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.grey500,
                    size: 22,
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Mot de passe obligatoire'
                      : null,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Se souvenir de moi & Mot de passe oublié
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.successGreen,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusSm,
                        ),
                        side: const BorderSide(
                          color: AppColors.grey500,
                          width: 1.5,
                        ),
                        onChanged: (val) {
                          setState(() => _rememberMe = val ?? false);
                        },
                      ),
                    ),
                    AppSpacing.gapSm,
                    Text(
                      'Se souvenir de moi',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // context.push('/forgot-password');
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlueAnthracite,
                        ),
                      ),
                    ),
                  ],
                ),

                if (auth.error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.08),
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: AppColors.errorRed.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      auth.error!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Bouton Se connecter
                PrimaryButton(
                  text: auth.loading ? 'Connexion…' : 'Se connecter',
                  onPressed: auth.loading ? null : _submit,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Séparateur
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: AppColors.borderLight)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text('ou', style: AppTextStyles.bodySmall),
                    ),
                    const Expanded(
                        child: Divider(color: AppColors.borderLight)),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Bouton Google
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.borderLight),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusXl,
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                        height: 20,
                        width: 20,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.g_mobiledata, size: 24),
                      ),
                      AppSpacing.gapSm,
                      Text(
                        'Se connecter avec Google',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlueAnthracite,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Lien Inscription
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Pas encore de compte ? ',
                      style: AppTextStyles.bodyMedium,
                      children: [
                        TextSpan(
                          text: "S'inscrire",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOcre,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/register'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
