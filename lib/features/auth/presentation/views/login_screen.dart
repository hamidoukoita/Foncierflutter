import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone_mali.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_sizes.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/redirection_demarrage.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_background.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_carte.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_entete.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/telephone_mali_prefixe.dart';
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
          TelephoneMali.chiffres(_phoneCtrl.text),
          _passwordCtrl.text,
        );
    if (!mounted) return;
    if (ok) context.go(dashboardDe(ref.read(authProvider).user));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: AuthBackground(
        child: SafeArea(
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

                  const AuthEntete(
                    titre: 'Bon retour parmi nous',
                    sousTitre: 'Connectez-vous à votre espace Foncier+',
                    hauteurLogo: 110,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  AuthCarte(
                    children: [
                      // Numéro de téléphone
                      AppTextField(
                        label: 'Numéro de téléphone',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        hintText: '76 12 34 56',
                        prefixIcon: const TelephoneMaliPrefixe(),
                        // inputFormatters: [TelephoneMaliFormatter()],
                        // validator: TelephoneMali.valider,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Mot de passe
                      AppTextField(
                        label: 'Mot de passe',
                        controller: _passwordCtrl,
                        isPassword: true,
                        hintText: 'Votre mot de passe',
                        prefixIcon:
                            const Icon(Icons.lock_outline_rounded, size: 22),
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
                        AuthErrorBanner(message: auth.error!),
                      ],

                      const SizedBox(height: AppSpacing.lg),

                      // Bouton Se connecter
                      PrimaryButton(
                        text: 'Se connecter',
                        icon: Icons.login_rounded,
                        isLoading: auth.loading,
                        onPressed: _submit,
                      ),
                    ],
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
                      minimumSize: const Size.fromHeight(AppSizes.buttonLarge),
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
                              ..onTap = () => context.push(AuthRoutes.register),
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
      ),
    );
  }
}
