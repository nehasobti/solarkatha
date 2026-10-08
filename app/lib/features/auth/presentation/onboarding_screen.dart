import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/indian_states.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../data/repositories/profile_repository.dart';
import '../application/session_controller.dart';

/// Shown to a signed-in user who has no company and no pending invite.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  String? _stateCode;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(profileRepositoryProvider)
          .createCompany(
            companyName: _companyController.text.trim(),
            stateCode: _stateCode!,
            ownerName: _nameController.text.trim(),
            language: ref.read(appPreferencesControllerProvider).languageCode,
          );
      await ref.read(sessionControllerProvider.notifier).reload();
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
    final lang = ref.watch(
      appPreferencesControllerProvider.select((p) => p.languageCode),
    );
    String? required(String? v) =>
        (v == null || v.trim().length < 2) ? l10n.requiredField : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingTitle),
        actions: [
          TextButton(
            onPressed: _busy
                ? null
                : () => ref.read(sessionControllerProvider.notifier).signOut(),
            child: Text(l10n.signOut),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.onboardingSubtitle,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_busy,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.yourNameLabel,
                      ),
                      validator: required,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyController,
                      enabled: !_busy,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.companyNameLabel,
                      ),
                      validator: required,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _stateCode,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.stateLabel),
                      items: [
                        for (final s in indianStates)
                          DropdownMenuItem(
                            value: s.code,
                            child: Text(s.name(lang)),
                          ),
                      ],
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _stateCode = v),
                      validator: (v) => v == null ? l10n.requiredField : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : Text(l10n.createCompany),
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
