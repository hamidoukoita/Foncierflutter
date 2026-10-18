import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_mobile_prospect_agent/core/network/error_handler.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_snackbar.dart';
import 'package:flutter_mobile_prospect_agent/shared/widgets/app_text_field.dart';
import 'compte_dialog.dart';

/// Changement du mot de passe : ancien, nouveau (6 caractères minimum) et confirmation.
class ChangerMotDePasseDialog extends ConsumerStatefulWidget {
  const ChangerMotDePasseDialog({super.key});

  static const int longueurMin = 6;

  static Future<void> show(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const ChangerMotDePasseDialog());

  @override
  ConsumerState<ChangerMotDePasseDialog> createState() => _ChangerMotDePasseDialogState();
}

class _ChangerMotDePasseDialogState extends ConsumerState<ChangerMotDePasseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ancien = TextEditingController();
  final _nouveau = TextEditingController();
  final _confirmation = TextEditingController();
  bool _enCours = false;

  @override
  void dispose() {
    _ancien.dispose();
    _nouveau.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enCours = true);
    try {
      await ref.read(authProvider.notifier).changerMotDePasse(ancien: _ancien.text, nouveau: _nouveau.text);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(context, 'Mot de passe mis à jour.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _enCours = false);
      AppSnackbar.error(context, ErrorHandler.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    const min = ChangerMotDePasseDialog.longueurMin;
    return CompteDialog(
      icone: Icons.key_rounded,
      titre: 'Changer mon mot de passe',
      sousTitre: 'Choisissez un mot de passe d’au moins $min caractères.',
      formKey: _formKey,
      libelleAction: 'Enregistrer',
      enCours: _enCours,
      onValider: _enregistrer,
      champs: [
        AppTextField(
          label: 'Mot de passe actuel',
          controller: _ancien,
          isPassword: true,
          validator: (v) => (v ?? '').isEmpty ? 'Obligatoire' : null,
        ),
        AppTextField(
          label: 'Nouveau mot de passe',
          controller: _nouveau,
          isPassword: true,
          validator: (v) {
            final s = v ?? '';
            if (s.trim().length < min) return '$min caractères minimum';
            return s == _ancien.text ? 'Choisissez un mot de passe différent' : null;
          },
        ),
        AppTextField(
          label: 'Confirmer le nouveau mot de passe',
          controller: _confirmation,
          isPassword: true,
          validator: (v) => v == _nouveau.text ? null : 'Les mots de passe ne correspondent pas',
        ),
      ],
    );
  }
}
