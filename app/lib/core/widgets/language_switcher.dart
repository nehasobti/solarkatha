import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../preferences/app_preferences.dart';

/// हिंदी / English toggle. [onChanged] runs after the local preference is
/// saved, e.g. to also store the choice on the user's profile.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final code = ref.watch(
      appPreferencesControllerProvider.select((p) => p.languageCode),
    );
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'hi', label: Text(l10n.languageHindi)),
        ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
      ],
      selected: {code},
      showSelectedIcon: false,
      onSelectionChanged: (selection) async {
        final value = selection.first;
        await ref
            .read(appPreferencesControllerProvider.notifier)
            .setLanguage(value);
        onChanged?.call(value);
      },
    );
  }
}
