import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_radius.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_spacing.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_text_styles.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_action_button.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/primary_button.dart';

/// Formulaire de modification du prénom et du nom de l'acquéreur.
class ModifierNomDialog extends ConsumerStatefulWidget {
  const ModifierNomDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
      context: context, builder: (_) => const ModifierNomDialog());

  @override
  ConsumerState<ModifierNomDialog> createState() => _ModifierNomDialogState();
}

class _ModifierNomDialogState extends ConsumerState<ModifierNomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _prenom =
      TextEditingController(text: ref.read(authProvider).user?.prenom ?? '');
  late final _nom =
      TextEditingController(text: ref.read(authProvider).user?.nom ?? '');
  bool _enCours = false;

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    super.dispose();
  }

  static String? _obligatoire(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null;

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enCours = true);
    try {
      await ref
          .read(authProvider.notifier)
          .modifierIdentite(nom: _nom.text, prenom: _prenom.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(context, 'Votre nom a été mis à jour.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _enCours = false);
      AppSnackbar.error(context, ErrorHandler.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                      color: AppColors.primaryOcreSoft, shape: BoxShape.circle),
                  child: const Icon(Icons.edit_rounded,
                      color: AppColors.primaryOcre, size: 26),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Modifier mon nom',
                  textAlign: TextAlign.center, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Il apparaîtra sur vos réservations et vos rendez-vous.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Prénom',
                controller: _prenom,
                prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                validator: _obligatoire,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Nom',
                controller: _nom,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                validator: _obligatoire,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                  text: 'Enregistrer',
                  icon: Icons.check_rounded,
                  isLoading: _enCours,
                  onPressed: _enregistrer),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.radiusMd,
                child: AppActionButton(
                  label: 'Annuler',
                  height: 44,
                  onPressed:
                      _enCours ? null : () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
