import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/telephone/champ_telephone.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/telephone/saisie_telephone.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/auth_routes.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_background.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_carte.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_entete.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/circle_icon_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

/// Mot de passe oublié, en deux étapes : numéro → code reçu par « SMS » (simulé, affiché à l'écran)
/// puis nouveau mot de passe.
class MotDePasseOublieScreen extends ConsumerStatefulWidget {
  const MotDePasseOublieScreen({super.key});

  @override
  ConsumerState<MotDePasseOublieScreen> createState() =>
      _MotDePasseOublieScreenState();
}

class _MotDePasseOublieScreenState
    extends ConsumerState<MotDePasseOublieScreen> {
  static const int _longueurMin = 6;

  final _formKey = GlobalKey<FormState>();
  final _telephone = SaisieTelephone();
  final _code = TextEditingController();
  final _nouveau = TextEditingController();
  final _confirmation = TextEditingController();

  /// Code simulé reçu ; null tant qu'on est à l'étape du numéro.
  String? _codeRecu;
  int _validiteMinutes = 10;
  bool _enCours = false;
  String? _erreur;

  @override
  void dispose() {
    _telephone.dispose();
    _code.dispose();
    _nouveau.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  String get _numero => _telephone.e164;

  Future<void> _executer(Future<void> Function() action) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _erreur = ErrorHandler.messageOf(e));
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _demanderCode() => _executer(() async {
        final reponse =
            await ref.read(authRepositoryProvider).demanderCode(_numero);
        if (!mounted) return;
        setState(() {
          _codeRecu = reponse.code;
          _validiteMinutes = reponse.validiteMinutes;
        });
      });

  Future<void> _reinitialiser() => _executer(() async {
        await ref.read(authRepositoryProvider).reinitialiserMotDePasse(
              telephone: _numero,
              code: _code.text.trim(),
              nouveau: _nouveau.text,
            );
        if (!mounted) return;
        AppSnackbar.success(
            context, 'Mot de passe réinitialisé : connectez-vous.');
        context.go(AuthRoutes.login);
      });

  @override
  Widget build(BuildContext context) {
    final etapeCode = _codeRecu != null;
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
                      icon: Icons.chevron_left_rounded,
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go(AuthRoutes.login),
                    ),
                  ),
                  AuthEntete(
                    titre: 'Mot de passe oublié',
                    sousTitre: etapeCode
                        ? 'Saisissez le code reçu et choisissez un nouveau mot de passe.'
                        : 'Indiquez votre numéro : nous vous envoyons un code de vérification.',
                    hauteurLogo: 72,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthCarte(
                    children: [
                      ChampTelephone(saisie: _telephone),
                      if (etapeCode) ...[
                        const SizedBox(height: AppSpacing.md),
                        _SmsSimule(
                            code: _codeRecu!,
                            validiteMinutes: _validiteMinutes),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Code reçu',
                          controller: _code,
                          keyboardType: TextInputType.number,
                          hintText: '6 chiffres',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6)
                          ],
                          validator: (v) => (v ?? '').trim().length == 6
                              ? null
                              : 'Le code compte 6 chiffres',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Nouveau mot de passe',
                          controller: _nouveau,
                          isPassword: true,
                          hintText: '$_longueurMin caractères minimum',
                          validator: (v) =>
                              (v ?? '').trim().length < _longueurMin
                                  ? '$_longueurMin caractères minimum'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Confirmer le mot de passe',
                          controller: _confirmation,
                          isPassword: true,
                          validator: (v) => v == _nouveau.text
                              ? null
                              : 'Les mots de passe ne correspondent pas',
                        ),
                      ],
                      if (_erreur != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        AuthErrorBanner(message: _erreur!),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        text: etapeCode
                            ? 'Réinitialiser le mot de passe'
                            : 'Recevoir un code',
                        icon: etapeCode
                            ? Icons.lock_reset_rounded
                            : Icons.sms_outlined,
                        isLoading: _enCours,
                        onPressed: etapeCode ? _reinitialiser : _demanderCode,
                      ),
                      if (etapeCode) ...[
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: _enCours ? null : _demanderCode,
                          child: const Text('Renvoyer un code'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bulle « SMS reçu » : le code est affiché faute de passerelle SMS (démonstration).
class _SmsSimule extends StatelessWidget {
  final String code;
  final int validiteMinutes;
  const _SmsSimule({required this.code, required this.validiteMinutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md - AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.successGreenSoft,
        borderRadius: AppRadius.radiusLg,
        border:
            Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sms_rounded, color: AppColors.successGreen),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SMS SIMULÉ · Foncier+', style: AppTextStyles.overline),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    text: 'Votre code : ',
                    style: AppTextStyles.bodyMedium,
                    children: [
                      TextSpan(
                        text: code,
                        style: AppTextStyles.h4.copyWith(
                            letterSpacing: 3,
                            color: AppColors.primaryBlueAnthracite),
                      ),
                    ],
                  ),
                ),
                Text('Valable $validiteMinutes minutes.',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
