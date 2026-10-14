import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_background.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_carte.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_entete.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/telephone_mali_prefixe.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

/// Inscription d'un acquéreur (Mali ou diaspora) : identité, contact, mot de passe.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const int _longueurMinMotDePasse = 6;
  static const int _chiffresMinTelephone = 8;

  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _acceptTerms = false;
  bool _conditionsManquantes = false;

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  /// Numéro sans espaces ni séparateurs, tel qu'il sera utilisé pour se connecter.
  String get _telephone => _phone.text.replaceAll(RegExp(r'[\s.-]'), '');

  String? _obligatoire(String? v) =>
      v == null || v.trim().isEmpty ? 'Obligatoire' : null;

  String? _validerTelephone(String? _) {
    final numero = _telephone;
    if (numero.isEmpty) return 'Numéro obligatoire';
    if (!RegExp(r'^\d+$').hasMatch(numero)) return 'Chiffres uniquement';
    if (numero.length < _chiffresMinTelephone) {
      return '$_chiffresMinTelephone chiffres minimum';
    }
    return null;
  }

  String? _validerMotDePasse(String? v) =>
      v == null || v.length < _longueurMinMotDePasse
          ? '$_longueurMinMotDePasse caractères minimum'
          : null;

  String? _validerConfirmation(String? v) {
    if (v == null || v.isEmpty) return 'Confirmez le mot de passe';
    return v == _password.text
        ? null
        : 'Les mots de passe ne correspondent pas';
  }

  void _retour() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AuthRoutes.login);
    }
  }

  Future<void> _submit() async {
    final formulaireValide = _formKey.currentState!.validate();
    setState(() => _conditionsManquantes = !_acceptTerms);
    if (!formulaireValide || !_acceptTerms) return;

    final ok = await ref.read(authProvider.notifier).registerAcquereur(
          nom: _nom.text,
          prenom: _prenom.text,
          telephone: _telephone,
          motDePasse: _password.text,
        );
    if (!mounted || !ok) return;
    final connecte = ref.read(authProvider).status == AuthStatus.authenticated;
    AppSnackbar.success(
      context,
      connecte
          ? 'Bienvenue sur Foncier+ !'
          : 'Compte créé. Connectez-vous pour continuer.',
    );
    context.go(connecte ? '/prospect/dashboard' : AuthRoutes.login);
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
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleIconButton(
                        icon: Icons.chevron_left_rounded, onPressed: _retour),
                  ),
                  const AuthEntete(
                    titre: 'Créez votre compte',
                    sousTitre:
                        'Réservez et visitez des terrains titrés, au Mali comme depuis la diaspora.',
                    hauteurLogo: 80,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthCarte(
                    children: [
                      const AuthSectionTitre(
                          icone: Icons.badge_outlined, titre: 'Identité'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Prénom',
                              controller: _prenom,
                              hintText: 'Amadou',
                              validator: _obligatoire,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md - AppSpacing.xs),
                          Expanded(
                            child: AppTextField(
                              label: 'Nom',
                              controller: _nom,
                              hintText: 'Traoré',
                              validator: _obligatoire,
                            ),
                          ),
                        ],
                      ),
                      const _Separateur(),
                      const AuthSectionTitre(
                          icone: Icons.phone_iphone_rounded, titre: 'Contact'),
                      AppTextField(
                        label: 'Numéro de téléphone',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        hintText: '76 12 34 56',
                        prefixIcon: const TelephoneMaliPrefixe(),
                        validator: _validerTelephone,
                      ),
                      const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                      Text(
                        'Il vous servira d’identifiant pour vous connecter.',
                        style: AppTextStyles.bodySmall,
                      ),
                      const _Separateur(),
                      const AuthSectionTitre(
                          icone: Icons.lock_outline_rounded, titre: 'Sécurité'),
                      AppTextField(
                        label: 'Mot de passe',
                        controller: _password,
                        isPassword: true,
                        hintText: '$_longueurMinMotDePasse caractères minimum',
                        validator: _validerMotDePasse,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Confirmer le mot de passe',
                        controller: _confirmation,
                        isPassword: true,
                        hintText: 'Saisissez-le à nouveau',
                        validator: _validerConfirmation,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _AccordConditions(
                        accepte: _acceptTerms,
                        enErreur: _conditionsManquantes,
                        onChanged: (v) => setState(() {
                          _acceptTerms = v;
                          if (v) _conditionsManquantes = false;
                        }),
                      ),
                      if (auth.error != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        AuthErrorBanner(message: auth.error!),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        text: 'Créer mon compte',
                        icon: Icons.person_add_alt_1_rounded,
                        isLoading: auth.loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _Garanties(),
                  const SizedBox(height: AppSpacing.lg),
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
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.go(AuthRoutes.login),
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

class _Separateur extends StatelessWidget {
  const _Separateur();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md + AppSpacing.xs),
      child: Divider(height: 1, color: AppColors.borderLight),
    );
  }
}

/// Case d'acceptation des Conditions générales et de la Charte TF.
class _AccordConditions extends StatelessWidget {
  final bool accepte;
  final bool enErreur;
  final ValueChanged<bool> onChanged;

  const _AccordConditions(
      {required this.accepte, required this.enErreur, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final lien = AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: AppRadius.radiusMd,
          onTap: () => onChanged(!accepte),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 22,
                width: 22,
                child: Checkbox(
                  value: accepte,
                  activeColor: AppColors.primaryBlueAnthracite,
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusSm),
                  side: BorderSide(
                    color:
                        enErreur ? AppColors.errorRed : AppColors.borderLight,
                    width: 1.5,
                  ),
                  onChanged: (v) => onChanged(v ?? false),
                ),
              ),
              const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: "J'accepte les ",
                    style: AppTextStyles.bodySmall,
                    children: [
                      TextSpan(
                        text: 'Conditions générales',
                        style: lien.copyWith(
                            color: AppColors.primaryBlueAnthracite),
                      ),
                      const TextSpan(text: ' et la '),
                      TextSpan(
                          text: 'Charte TF',
                          style: lien.copyWith(color: AppColors.primaryOcre)),
                      const TextSpan(text: ' de Foncier+.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (enErreur) ...[
          const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
          Text(
            'Acceptez les conditions pour créer votre compte.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.errorRed),
          ),
        ],
      ],
    );
  }
}

/// Engagements de la plateforme, rappelés sous le formulaire.
class _Garanties extends StatelessWidget {
  const _Garanties();

  static const _items = [
    (Icons.verified_outlined, 'Titres fonciers vérifiés'),
    (Icons.apartment_rounded, 'Sociétés agréées'),
    (Icons.payments_outlined, 'Aucun paiement en ligne'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (icone, libelle) in _items)
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: const BoxDecoration(
                      color: AppColors.successGreenSoft,
                      shape: BoxShape.circle),
                  child: Icon(icone, size: 18, color: AppColors.successGreen),
                ),
                const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                Text(
                  libelle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
