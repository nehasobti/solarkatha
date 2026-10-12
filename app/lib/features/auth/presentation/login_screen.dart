import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../data/repositories/auth_repository.dart';
import '../domain/validators.dart';

/// Private sign-in: mobile number + password. Accounts are created by the
/// administrator (no self sign-up); a member's first sign-in claims their
/// team invite and the router moves on.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithPassword(
            phone: normalizeIndianMobile(_phone.text)!,
            password: _password.text,
          );
    } catch (e) {
      if (mounted) setState(() => _error = describeError(context.l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final login = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(child: LanguageSwitcher()),
                const SizedBox(height: 32),
                const Center(child: BrandMark(size: 64)),
                const SizedBox(height: 8),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  l10n.appTagline,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(l10n.loginTitle, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(l10n.loginPasswordSubtitle),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('login.id'),
                  controller: _phone,
                  enabled: !_busy,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  ],
                  style: theme.textTheme.titleMedium,
                  decoration: InputDecoration(
                    labelText: l10n.phoneLabel,
                    hintText: l10n.phoneHint,
                    prefixText: '+91 ',
                  ),
                  validator: (v) => normalizeIndianMobile(v ?? '') != null
                      ? null
                      : l10n.invalidPhone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('login.password'),
                  controller: _password,
                  enabled: !_busy,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  style: theme.textTheme.titleMedium,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    suffixIcon: IconButton(
                      tooltip: l10n.showPassword,
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v ?? '').isEmpty ? l10n.requiredField : null,
                  onFieldSubmitted: (_) => _signIn(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('login.submit'),
                  onPressed: _busy ? null : _signIn,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Text(l10n.signInButton),
                ),
                if (kIsWeb) ...[const SizedBox(height: 12), const ApkButton()],
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  const Expanded(child: LandingHero()),
                  Expanded(child: Center(child: login)),
                ],
              )
            : Center(child: login),
      ),
    );
  }
}

/// Web only: the signed Android APK served next to the web app.
class ApkButton extends StatelessWidget {
  const ApkButton({super.key});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const Key('login.apk'),
    onPressed: () => launchUrl(Uri.base.resolve('/solarkatha.apk')),
    icon: const Icon(Icons.android),
    label: Text(context.l10n.downloadApk),
  );
}

/// Left half of the web landing page: pitch and features.
class LandingHero extends StatelessWidget {
  const LandingHero({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    const fg = Colors.white;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 56),
                const SizedBox(height: 12),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.landingHeadline,
                  style: theme.textTheme.headlineSmall?.copyWith(color: fg),
                ),
                const SizedBox(height: 28),
                for (final f in [
                  l10n.landingF1,
                  l10n.landingF2,
                  l10n.landingF3,
                  l10n.landingF4,
                  l10n.landingF5,
                  l10n.landingF6,
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: fg, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            f,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: fg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
