import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/telephone/champ_telephone.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/telephone/saisie_telephone.dart';
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
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephone = SaisieTelephone();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _telephone.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(
          _telephone.e164,
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
                      ChampTelephone(saisie: _telephone),

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
