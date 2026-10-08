import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                    Icon(
                      Icons.wb_sunny,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
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
                    Text(
                      isPhone ? l10n.loginSubtitle : l10n.loginEmailSubtitle,
                    ),
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
                            ? [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9+ ]'),
                                ),
                              ]
                            : null,
                        style: theme.textTheme.titleMedium,
                        decoration: InputDecoration(
                          labelText: isPhone
                              ? l10n.phoneLabel
                              : l10n.emailLabel,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('login.submit'),
                      onPressed: _busy
                          ? null
                          : (awaitingOtp ? _verify : _sendCode),
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
                  ],
                ),
              ),
            ),
          ),
        ),
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
