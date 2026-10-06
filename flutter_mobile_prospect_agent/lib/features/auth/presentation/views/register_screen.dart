import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile_prospect_agent/core/theme/app_colors.dart';
import 'package:flutter_mobile_prospect_agent/features/auth/presentation/controllers/auth_provider.dart';
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
    final ok = await ref.read(authProvider.notifier).registerAcquereur(
          nom: _nom.text,
          prenom: _prenom.text,
          telephone: _phone.text,
          motDePasse: _password.text,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription enregistrée. Connectez-vous si besoin.')),
      );
      final user = ref.read(authProvider).user;
      if (user != null) {
        context.go('/prospect');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription acquéreur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _prenom,
                decoration: const InputDecoration(labelText: 'Prénom *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nom,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Téléphone *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe *'),
                validator: (v) =>
                    v == null || v.length < 4 ? 'Min. 4 caractères' : null,
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 16),
                Text(auth.error!, style: const TextStyle(color: AppColors.errorRed)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                text: auth.loading ? 'Inscription…' : 'S’inscrire',
                onPressed: auth.loading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
