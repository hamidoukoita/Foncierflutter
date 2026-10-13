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
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_background.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_sizes.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _acceptTerms = true;

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions générales.'),
        ),
      );
      return;
    }
    final ok = await ref.read(authProvider.notifier).registerAcquereur(
          nom: _nom.text,
          prenom: _prenom.text,
          telephone: _phone.text,
          motDePasse: _password.text,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription enregistrée. Connectez-vous si besoin.'),
        ),
      );
      final user = ref.read(authProvider).user;
      if (user != null) {
        context.go('/prospect/dashboard');
      } else {
        context.go('/login');
      }
    }
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
              vertical: AppSpacing.md,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bouton retour circulaire
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleIconButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/login');
                        }
                      },
                    ),
                  ),

                  // Logo Foncier+
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 130,
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

                  // Titre et sous-titre
                  Text(
                    'Créez votre compte',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pageTitle,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    'Rejoignez la plateforme foncière certifiée',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Prénom et Nom côte à côte
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Prénom',
                          controller: _prenom,
                          hintText: 'Amadou',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.grey500,
                            size: 20,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Obligatoire'
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Nom',
                          controller: _nom,
                          hintText: 'Traoré',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Obligatoire'
                              : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Numéro de téléphone
                  AppTextField(
                    label: 'Numéro de téléphone',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    hintText: '76 12 34 56',
                    prefix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇲🇱', style: TextStyle(fontSize: 18)),
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
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Obligatoire' : null,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Mot de passe
                  AppTextField(
                    label: 'Mot de passe',
                    controller: _password,
                    isPassword: true,
                    hintText: '••••••••',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.grey500,
                      size: 20,
                    ),
                    validator: (v) =>
                        v == null || v.length < 4 ? 'Min. 4 caractères' : null,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Conditions Générales & Charte TF
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 22,
                        width: 22,
                        child: Checkbox(
                          value: _acceptTerms,
                          activeColor: AppColors.primaryBlueAnthracite,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusSm,
                          ),
                          side: const BorderSide(
                            color: AppColors.borderLight,
                            width: 1.5,
                          ),
                          onChanged: (val) {
                            setState(() => _acceptTerms = val ?? false);
                          },
                        ),
                      ),
                      AppSpacing.gapSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "J'accepte les ",
                                style: AppTextStyles.bodySmall,
                                children: [
                                  TextSpan(
                                    text: 'Conditions Générales',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlueAnthracite,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                  const TextSpan(text: ' et la '),
                                  TextSpan(
                                    text: 'Charte TF',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryOcre,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.gapXs,
                            Row(
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.successGreen,
                                ),
                                AppSpacing.gapXs,
                                Text(
                                  'Garantie 100% Titres Fonciers individuels',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.successGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (auth.error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AuthErrorBanner(message: auth.error!),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // Bouton S'inscrire
                  PrimaryButton(
                    text: "Créer mon compte",
                    icon: Icons.person_add_alt_1_rounded,
                    isLoading: auth.loading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Séparateur ou
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
                          '',
                          height: 20,
                          width: 20,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata, size: 24),
                        ),
                        AppSpacing.gapSm,
                        Text(
                          "S'inscrire avec Google",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlueAnthracite,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Lien Se connecter
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Vous avez déjà un compte ? ',
                        style: AppTextStyles.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryOcre,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.go('/login'),
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
