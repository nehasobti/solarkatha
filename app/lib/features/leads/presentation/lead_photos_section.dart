import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/l10n.dart';
import '../../../data/powersync/powersync_providers.dart';
import '../application/leads_providers.dart';
import '../data/leads_repository.dart';
import '../domain/lead.dart';
import 'lead_ui.dart';

/// Photo checklist (roof, meter, DB box, wiring path) plus extra photos.
/// Photos are saved on the phone first and uploaded by the queue.
class LeadPhotosSection extends ConsumerWidget {
  const LeadPhotosSection({super.key, required this.lead});

  final Lead lead;

  Future<void> _add(BuildContext context, WidgetRef ref, PhotoKind kind) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!lead.hasConsent) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.consentRequiredForPhotos)),
      );
      return;
    }
    final source = kIsWeb
        ? ImageSource.gallery
        : await showModalBottomSheet<ImageSource>(
            context: context,
            showDragHandle: true,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: Text(l10n.takePhoto),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: Text(l10n.chooseFromGallery),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          );
    if (source == null) return;

    // Spec: max 1600 px, JPEG 80%.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (file == null) return;
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    try {
      await ref
          .read(leadsRepositoryProvider)
          .addPhoto(
            lead: lead,
            kind: kind,
            jpeg: await file.readAsBytes(),
            userId: member.profile.id,
          );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final photos = ref.watch(leadPhotosProvider(lead.id)).value ?? const [];
    final done = checklistPhotoKinds
        .where((k) => photos.any((p) => p.kind == k))
        .length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.photosTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.photosChecklist(done, checklistPhotoKinds.length),
              style: theme.textTheme.labelLarge?.copyWith(
                color: done == checklistPhotoKinds.length
                    ? const Color(0xFF2E7D32)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: done / checklistPhotoKinds.length,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final kind in [
                  ...checklistPhotoKinds,
                  PhotoKind.other,
                ]) ...[
                  for (final p in photos.where((p) => p.kind == kind))
                    _PhotoTile(photo: p),
                  if (kind == PhotoKind.other ||
                      !photos.any((p) => p.kind == kind))
                    _AddTile(kind: kind, onTap: () => _add(context, ref, kind)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const _tileSize = 104.0;

class _AddTile extends StatelessWidget {
  const _AddTile({required this.kind, required this.onTap});

  final PhotoKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.square(
      dimension: _tileSize,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(kind.icon, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text(
                kind.label(context.l10n),
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              Icon(Icons.add, size: 16, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends ConsumerStatefulWidget {
  const _PhotoTile({required this.photo});

  final LeadPhoto photo;

  @override
  ConsumerState<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends ConsumerState<_PhotoTile> {
  Future<Uint8List?>? _bytes;
  String? _loadedUri;

  Future<Uint8List?> _read(String uri) async {
    final storage = ref.read(localDataProvider).photoStorage;
    if (!await storage.fileExists(uri)) return null;
    final b = BytesBuilder(copy: false);
    await for (final chunk in storage.readFile(uri)) {
      b.add(chunk);
    }
    return b.takeBytes();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final uri = widget.photo.localUri;
    if (uri != null && uri != _loadedUri) {
      _loadedUri = uri;
      _bytes = _read(uri);
    }

    return SizedBox.square(
      dimension: _tileSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<Uint8List?>(
              future: _bytes,
              builder: (context, snap) => snap.data == null
                  ? ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(widget.photo.kind.icon),
                    )
                  : GestureDetector(
                      onTap: () => _open(context, snap.data!),
                      child: Image.memory(snap.data!, fit: BoxFit.cover),
                    ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: Colors.black54,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.photo.kind.label(l10n),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!widget.photo.uploaded)
                      Tooltip(
                        message: l10n.photoWaiting,
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Uint8List bytes) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: InteractiveViewer(child: Image.memory(bytes))),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(leadsRepositoryProvider)
                        .deletePhoto(widget.photo.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.deletePhoto),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    MaterialLocalizations.of(context).closeButtonLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
