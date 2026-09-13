import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sport_team_manager/core/auth/auth_gateway.dart';

enum AuthPageMode { signIn, register, resetPassword }

class AuthPage extends StatefulWidget {
  const AuthPage({required this.authGateway, super.key});

  final AuthGateway authGateway;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthPageMode _mode = AuthPageMode.signIn;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setMode(AuthPageMode mode) {
    setState(() {
      _mode = mode;
      _message = null;
      _messageIsError = false;
      _passwordController.clear();
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      switch (_mode) {
        case AuthPageMode.signIn:
          await widget.authGateway.signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
        case AuthPageMode.register:
          await widget.authGateway.register(
            displayName: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
        case AuthPageMode.resetPassword:
          await widget.authGateway.sendPasswordResetEmail(
            _emailController.text,
          );
          if (!mounted) return;
          setState(() {
            _message = 'E-mail de réinitialisation envoyé.';
            _messageIsError = false;
          });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _firebaseErrorMessage(error.code);
        _messageIsError = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Une erreur est survenue. Réessaie dans un instant.';
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRegister = _mode == AuthPageMode.register;
    final isReset = _mode == AuthPageMode.resetPassword;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.sports_soccer,
                          size: 34,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isRegister
                          ? 'Créer mon compte'
                          : isReset
                              ? 'Mot de passe oublié'
                              : 'Bienvenue sur le terrain',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRegister
                          ? 'Commence par créer ton profil Sport Team Manager.'
                          : isReset
                              ? 'Indique ton adresse e-mail pour recevoir un lien.'
                              : 'Connecte-toi pour retrouver ton équipe.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 28),
                    if (isRegister) ...[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: const InputDecoration(
                          labelText: 'Prénom et nom',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().length < 2
                                ? 'Indique ton nom.'
                                : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction:
                          isReset ? TextInputAction.done : TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Adresse e-mail',
                        prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateEmail,
                      onFieldSubmitted: isReset ? (_) => _submit() : null,
                    ),
                    if (!isReset) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: isRegister
                            ? const [AutofillHints.newPassword]
                            : const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Afficher le mot de passe'
                                : 'Masquer le mot de passe',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.length < 6
                            ? 'Utilise au moins 6 caractères.'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color:
                                _messageIsError ? colors.error : colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              isRegister
                                  ? 'Créer mon compte'
                                  : isReset
                                      ? 'Envoyer le lien'
                                      : 'Se connecter',
                            ),
                    ),
                    if (_mode == AuthPageMode.signIn)
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => _setMode(AuthPageMode.resetPassword),
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => _setMode(
                                isRegister || isReset
                                    ? AuthPageMode.signIn
                                    : AuthPageMode.register,
                              ),
                      child: Text(
                        isRegister || isReset
                            ? 'Retour à la connexion'
                            : 'Pas encore de compte ? Créer un compte',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Indique une adresse e-mail valide.';
  }
  return null;
}

String _firebaseErrorMessage(String code) {
  return switch (code) {
    'invalid-email' => 'Cette adresse e-mail n’est pas valide.',
    'email-already-in-use' => 'Un compte utilise déjà cette adresse e-mail.',
    'weak-password' => 'Choisis un mot de passe plus robuste.',
    'invalid-credential' || 'user-not-found' || 'wrong-password' =>
      'E-mail ou mot de passe incorrect.',
    'user-disabled' => 'Ce compte a été désactivé.',
    'too-many-requests' => 'Trop de tentatives. Réessaie plus tard.',
    'network-request-failed' => 'Vérifie ta connexion internet.',
    'operation-not-allowed' =>
      'La connexion e-mail/mot de passe n’est pas activée.',
    _ => 'Impossible de continuer. Réessaie dans un instant.',
  };
}
