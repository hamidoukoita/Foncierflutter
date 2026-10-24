import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/core/utils/nom_personne.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/widgets/compte/compte_dialog.dart';

/// Formulaire de modification du prénom et du nom de l'acquéreur (lettres uniquement).
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
    return CompteDialog(
      icone: Icons.edit_rounded,
      titre: 'Modifier mon nom',
      sousTitre: 'Il apparaîtra sur vos réservations et vos rendez-vous.',
      formKey: _formKey,
      libelleAction: 'Enregistrer',
      enCours: _enCours,
      onValider: _enregistrer,
      champs: [
        AppTextField(
          label: 'Prénom',
          controller: _prenom,
          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
          inputFormatters: NomPersonne.formatters,
          validator: (v) => NomPersonne.valider(v, libelle: 'Prénom'),
        ),
        AppTextField(
          label: 'Nom',
          controller: _nom,
          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
          inputFormatters: NomPersonne.formatters,
          validator: (v) => NomPersonne.valider(v, libelle: 'Nom'),
        ),
      ],
    );
  }
}
