import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../data/repositories/auth_repository.dart';
import '../domain/validators.dart';

enum _Method { phone, email }

/// Phone OTP for everyone, email OTP for owners. On success the session
/// controller picks up the new user and the router moves on.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _otpController = TextEditingController();

  _Method _method = _Method.phone;
  String? _sentTo;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _idController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _normalizedId() => _method == _Method.phone
      ? normalizeIndianMobile(_idController.text)
      : normalizeEmail(_idController.text);

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = describeError(context.l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _normalizedId()!;
    final auth = ref.read(authRepositoryProvider);
    await _run(() async {
      if (_method == _Method.phone) {
        await auth.sendPhoneOtp(id);
      } else {
        await auth.sendEmailOtp(id);
      }
      if (mounted) setState(() => _sentTo = id);
    });
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authRepositoryProvider);
    final token = _otpController.text.trim();
    await _run(() async {
      if (_method == _Method.phone) {
        await auth.verifyPhoneOtp(phone: _sentTo!, token: token);
      } else {
        await auth.verifyEmailOtp(email: _sentTo!, token: token);
      }
    });
  }

  /// One-tap demo login with the Supabase test numbers (fixed OTP).
  Future<void> _demo(String phone) async {
    final auth = ref.read(authRepositoryProvider);
    await _run(() async {
      await auth.sendPhoneOtp(phone);
      await auth.verifyPhoneOtp(phone: phone, token: demoOtp);
    });
  }

  void _reset({_Method? method}) {
    setState(() {
      _method = method ?? _method;
      _sentTo = null;
      _error = null;
      _otpController.clear();
      if (method != null) _idController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isPhone = _method == _Method.phone;
    final awaitingOtp = _sentTo != null;

    final wide = MediaQuery.sizeOf(context).width >= 900;
    final login = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(child: LanguageSwitcher()),
              const SizedBox(height: 32),
              Icon(Icons.wb_sunny, size: 56, color: theme.colorScheme.primary),
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
              Text(isPhone ? l10n.loginSubtitle : l10n.loginEmailSubtitle),
              const SizedBox(height: 16),
              if (!awaitingOtp)
                TextFormField(
                  key: const Key('login.id'),
                  controller: _idController,
                  enabled: !_busy,
                  autofocus: true,
                  keyboardType: isPhone
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  autofillHints: [
                    isPhone
                        ? AutofillHints.telephoneNumberNational
                        : AutofillHints.email,
                  ],
                  inputFormatters: isPhone
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))]
                      : null,
                  style: theme.textTheme.titleMedium,
                  decoration: InputDecoration(
                    labelText: isPhone ? l10n.phoneLabel : l10n.emailLabel,
                    hintText: isPhone ? l10n.phoneHint : null,
                    prefixText: isPhone ? '+91 ' : null,
                  ),
                  validator: (_) => _normalizedId() != null
                      ? null
                      : (isPhone ? l10n.invalidPhone : l10n.invalidEmail),
                  onFieldSubmitted: (_) => _sendCode(),
                )
              else ...[
                Row(
                  children: [
                    Expanded(child: Text(l10n.otpSentTo(_sentTo!))),
                    TextButton(
                      onPressed: _busy ? null : _reset,
                      child: Text(l10n.changeNumber),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('login.otp'),
                  controller: _otpController,
                  enabled: !_busy,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    letterSpacing: 8,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: l10n.otpLabel,
                    counterText: '',
                  ),
                  validator: (v) =>
                      isValidOtp(v ?? '') ? null : l10n.invalidOtp,
                  onFieldSubmitted: (_) => _verify(),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('login.submit'),
                onPressed: _busy ? null : (awaitingOtp ? _verify : _sendCode),
                child: _busy
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : Text(awaitingOtp ? l10n.verifyOtp : l10n.sendOtp),
              ),
              if (awaitingOtp)
                TextButton(
                  onPressed: _busy ? null : _sendCodeAgain,
                  child: Text(l10n.resendOtp),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _reset(
                        method: isPhone ? _Method.email : _Method.phone,
                      ),
                child: Text(
                  isPhone ? l10n.useEmailInstead : l10n.usePhoneInstead,
                ),
              ),
              const SizedBox(height: 16),
              _DemoCard(busy: _busy, onPick: _demo),
            ],
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

  Future<void> _sendCodeAgain() async {
    final id = _sentTo!;
    final auth = ref.read(authRepositoryProvider);
    await _run(
      () => _method == _Method.phone
          ? auth.sendPhoneOtp(id)
          : auth.sendEmailOtp(id),
    );
  }
}

/// Test numbers configured in Supabase Auth (Phone > test OTPs).
const demoOtp = '123456';
const demoPhones = {
  'owner': '+919999900001',
  'sales': '+919999900002',
  'installer': '+919999900003',
};

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.busy, required this.onPick});

  final bool busy;
  final void Function(String phone) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.demoTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.demoBody, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (role, label, icon) in [
                  ('owner', l10n.demoAsOwner, Icons.insights),
                  ('sales', l10n.demoAsSales, Icons.person_search),
                  ('installer', l10n.demoAsInstaller, Icons.engineering),
                ])
                  FilledButton.tonalIcon(
                    key: Key('login.demo.$role'),
                    onPressed: busy ? null : () => onPick(demoPhones[role]!),
                    icon: Icon(icon, size: 18),
                    label: Text(label),
                  ),
              ],
            ),
          ],
        ),
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
          colors: [Color(0xFFE07B00), Color(0xFFB34700)],
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
                const Icon(Icons.wb_sunny, size: 48, color: fg),
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
