import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/indian_states.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/router/routes.dart';
import '../../../data/models/user_role.dart';
import '../../auth/domain/validators.dart';
import '../application/leads_providers.dart';
import '../data/leads_repository.dart';
import '../domain/lead.dart';
import 'lead_ui.dart';

/// Create ([leadId] null) or edit a lead. Saves to the device; works offline.
/// Typing is saved as a draft so nothing is lost if the app closes.
class LeadFormScreen extends ConsumerStatefulWidget {
  const LeadFormScreen({super.key, this.leadId});

  final String? leadId;

  @override
  ConsumerState<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends ConsumerState<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _altPhone = TextEditingController();
  final _address = TextEditingController();
  final _district = TextEditingController();
  final _pincode = TextEditingController();
  final _notes = TextEditingController();

  LeadInput _input = const LeadInput();
  Lead? _original;
  bool _loaded = false;
  bool _saving = false;
  bool _locating = false;
  Timer? _draftTimer;

  String get _draftKey => 'draft.lead.${widget.leadId ?? 'new'}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final member = ref.read(currentMemberProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    var input = LeadInput(stateCode: member?.company.stateCode);
    if (widget.leadId != null) {
      _original = await ref
          .read(leadsRepositoryProvider)
          .watchLead(widget.leadId!)
          .first;
      if (_original != null) input = LeadInput.fromLead(_original!);
    }
    final draft = decodeDraft(prefs.getString(_draftKey));
    if (draft != null && draft != input) {
      input = draft;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.draftRestored),
            action: SnackBarAction(
              label: context.l10n.discardDraft,
              onPressed: _discardDraft,
            ),
          ),
        );
      });
    }
    _apply(input);
    setState(() => _loaded = true);
  }

  void _apply(LeadInput input) {
    _input = input;
    _name.text = input.name;
    _phone.text = input.phone;
    _altPhone.text = input.altPhone;
    _address.text = input.address;
    _district.text = input.district;
    _pincode.text = input.pincode;
    _notes.text = input.notes;
  }

  Future<void> _discardDraft() async {
    await ref.read(sharedPreferencesProvider).remove(_draftKey);
    final base = _original != null
        ? LeadInput.fromLead(_original!)
        : LeadInput(
            stateCode: ref.read(currentMemberProvider)?.company.stateCode,
          );
    setState(() => _apply(base));
  }

  LeadInput _collect() => _input.copyWith(
    name: _name.text,
    phone: _phone.text,
    altPhone: _altPhone.text,
    address: _address.text,
    district: _district.text,
    pincode: _pincode.text,
    notes: _notes.text,
  );

  void _changed([LeadInput? next]) {
    if (next != null) setState(() => _input = next);
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 600), () {
      ref
          .read(sharedPreferencesProvider)
          .setString(_draftKey, encodeDraft(_collect()));
    });
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    for (final c in [
      _name,
      _phone,
      _altPhone,
      _address,
      _district,
      _pincode,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _captureLocation() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw Exception();
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      _changed(_input.copyWith(lat: pos.latitude, lng: pos.longitude));
      messenger.showSnackBar(SnackBar(content: Text(l10n.locationCaptured)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.locationFailed)));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickFollowUp() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _input.nextFollowUpAt?.toLocal() ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _changed(
        _input.copyWith(
          nextFollowUpAt: DateTime(picked.year, picked.month, picked.day, 10),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    final l10n = context.l10n;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    final input = _collect().copyWith(
      phone: normalizeIndianMobile(_phone.text)!.substring(3),
      altPhone: _altPhone.text.trim().isEmpty
          ? ''
          : normalizeIndianMobile(_altPhone.text)!.substring(3),
    );
    final repo = ref.read(leadsRepositoryProvider);
    try {
      String id;
      if (widget.leadId == null) {
        id = await repo.createLead(
          input: input,
          companyId: member.company.id,
          userId: member.profile.id,
        );
      } else {
        id = widget.leadId!;
        await repo.updateLead(id, input, previous: _original);
      }
      _draftTimer?.cancel();
      await ref.read(sharedPreferencesProvider).remove(_draftKey);
      messenger.showSnackBar(SnackBar(content: Text(l10n.leadSaved)));
      if (widget.leadId == null) {
        unawaited(router.pushReplacement(Routes.lead(id)));
      } else {
        router.pop();
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e))));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final member = ref.watch(currentMemberProvider);
    final isOwner = member?.profile.role == UserRole.owner;
    final lang = ref.watch(
      appPreferencesControllerProvider.select((p) => p.languageCode),
    );

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String? requiredText(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.requiredField : null;

    Widget section(String title, IconData icon, List<Widget> children) => Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children.expand((w) => [w, const SizedBox(height: 12)]).toList()
              ..removeLast(),
          ],
        ),
      ),
    );

    final phoneFormatters = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
      LengthLimitingTextInputFormatter(14),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leadId == null ? l10n.newLead : l10n.editLead),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            key: const Key('leadForm.save'),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(l10n.saveLead),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: _changed,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                section(l10n.customerSection, Icons.person_outline, [
                  TextFormField(
                    key: const Key('leadForm.name'),
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: l10n.leadNameLabel),
                    validator: requiredText,
                  ),
                  TextFormField(
                    key: const Key('leadForm.phone'),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: phoneFormatters,
                    decoration: InputDecoration(
                      labelText: l10n.leadPhoneLabel,
                      prefixText: '+91 ',
                    ),
                    validator: (v) => normalizeIndianMobile(v ?? '') == null
                        ? l10n.invalidPhone
                        : null,
                  ),
                  TextFormField(
                    controller: _altPhone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: phoneFormatters,
                    decoration: InputDecoration(
                      labelText: l10n.leadAltPhoneLabel,
                      prefixText: '+91 ',
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ||
                            normalizeIndianMobile(v!) != null
                        ? null
                        : l10n.invalidPhone,
                  ),
                  DropdownButtonFormField<LeadSource>(
                    initialValue: _input.source,
                    decoration: InputDecoration(
                      labelText: l10n.leadSourceLabel,
                    ),
                    items: [
                      for (final s in LeadSource.values)
                        DropdownMenuItem(value: s, child: Text(s.label(l10n))),
                    ],
                    onChanged: (v) => _changed(_input.copyWith(source: v!)),
                  ),
                  if (isOwner)
                    _AssigneeField(
                      value: _input.assignedTo ?? member?.profile.id,
                      onChanged: (v) =>
                          _changed(_input.copyWith(assignedTo: v)),
                    ),
                  CheckboxListTile(
                    key: const Key('leadForm.consent'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _input.consent,
                    onChanged: (_original?.hasConsent ?? false)
                        ? null
                        : (v) => _changed(_input.copyWith(consent: v ?? false)),
                    title: Text(l10n.consentLabel),
                  ),
                ]),
                section(l10n.addressSection, Icons.place_outlined, [
                  TextFormField(
                    controller: _address,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      labelText: l10n.leadAddressLabel,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _district,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: l10n.leadDistrictLabel,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: TextFormField(
                          controller: _pincode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.leadPincodeLabel,
                          ),
                          validator: (v) =>
                              (v ?? '').isEmpty ||
                                  RegExp(r'^[1-9]\d{5}$').hasMatch(v!)
                              ? null
                              : l10n.invalidPincode,
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _input.stateCode,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.stateLabel),
                    items: [
                      for (final s in indianStates)
                        DropdownMenuItem(
                          value: s.code,
                          child: Text(s.name(lang)),
                        ),
                    ],
                    onChanged: (v) => _changed(_input.copyWith(stateCode: v)),
                  ),
                  OutlinedButton.icon(
                    onPressed: _locating ? null : _captureLocation,
                    icon: _locating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _input.lat != null
                                ? Icons.where_to_vote
                                : Icons.my_location,
                          ),
                    label: Text(
                      _input.lat != null
                          ? '${l10n.locationCaptured} (${_input.lat!.toStringAsFixed(5)}, ${_input.lng!.toStringAsFixed(5)})'
                          : l10n.captureLocation,
                    ),
                  ),
                ]),
                section(l10n.followUpSection, Icons.event_outlined, [
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.followUpLabel,
                      suffixIcon: _input.nextFollowUpAt == null
                          ? null
                          : IconButton(
                              tooltip: l10n.clear,
                              icon: const Icon(Icons.close),
                              onPressed: () => _changed(
                                _input.copyWith(nextFollowUpAt: null),
                              ),
                            ),
                    ),
                    child: InkWell(
                      onTap: _pickFollowUp,
                      child: Text(
                        _input.nextFollowUpAt == null
                            ? l10n.followUpNone
                            : formatDay(context, _input.nextFollowUpAt!),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _notes,
                    maxLines: 4,
                    minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: l10n.leadNotesLabel),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssigneeField extends ConsumerWidget {
  const _AssigneeField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final team = (ref.watch(teamProvider).value ?? const [])
        .where((m) => m.role != 'installer')
        .toList();
    final known = team.any((m) => m.id == value);
    return DropdownButtonFormField<String>(
      initialValue: known ? value : null,
      decoration: InputDecoration(labelText: l10n.assignedToLabel),
      items: [
        for (final m in team)
          DropdownMenuItem(value: m.id, child: Text(m.name)),
      ],
      onChanged: onChanged,
    );
  }
}
