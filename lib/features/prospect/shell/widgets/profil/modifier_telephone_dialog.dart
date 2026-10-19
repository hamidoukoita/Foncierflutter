import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/telephone_mali.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/telephone_mali_prefixe.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/compte/compte_dialog.dart';

/// Changement du numéro de connexion, confirmé par le mot de passe actuel.
class ModifierTelephoneDialog extends ConsumerStatefulWidget {
  const ModifierTelephoneDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
      context: context, builder: (_) => const ModifierTelephoneDialog());

  @override
  ConsumerState<ModifierTelephoneDialog> createState() =>
      _ModifierTelephoneDialogState();
}

class _ModifierTelephoneDialogState
    extends ConsumerState<ModifierTelephoneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _telephone = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _enCours = false;

  @override
  void dispose() {
    _telephone.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  String? _validerTelephone(String? v) {
    final erreur = TelephoneMali.valider(v);
    if (erreur != null) return erreur;
    final actuel = ref.read(authProvider).user?.telephone;
    return TelephoneMali.chiffres(v!) == actuel
        ? 'C’est déjà votre numéro'
        : null;
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enCours = true);
    try {
      await ref.read(authProvider.notifier).changerTelephone(
            nouveauTelephone: TelephoneMali.chiffres(_telephone.text),
            motDePasse: _motDePasse.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(
          context, 'Numéro mis à jour : utilisez-le pour vous connecter.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _enCours = false);
      AppSnackbar.error(context, ErrorHandler.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompteDialog(
      icone: Icons.phone_iphone_rounded,
      titre: 'Changer de numéro',
      sousTitre:
          'Votre nouveau numéro deviendra votre identifiant de connexion.',
      formKey: _formKey,
      libelleAction: 'Changer de numéro',
      enCours: _enCours,
      onValider: _enregistrer,
      champs: [
        AppTextField(
          label: 'Nouveau numéro',
          controller: _telephone,
          keyboardType: TextInputType.phone,
          hintText: '76 12 34 56',
          prefixIcon: const TelephoneMaliPrefixe(),
          inputFormatters: [TelephoneMaliFormatter()],
          validator: _validerTelephone,
        ),
        AppTextField(
          label: 'Mot de passe actuel',
          controller: _motDePasse,
          isPassword: true,
          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
          validator: (v) =>
              (v ?? '').isEmpty ? 'Confirmez avec votre mot de passe' : null,
        ),
      ],
    );
  }
}
