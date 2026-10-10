import 'dart:convert';
import 'dart:typed_data';

import 'package:latlong2/latlong.dart';
import 'package:powersync/powersync.dart';
import 'package:powersync_core/attachments/attachments.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_core/solar_core.dart';
import 'package:uuid/uuid.dart';

import '../../../data/powersync/powersync_providers.dart';
import '../../../data/powersync/schema.dart';
import '../domain/roof_geometry.dart';
import '../domain/site.dart';

part 'survey_repository.g.dart';

const _uuid = Uuid();
String _now() => DateTime.now().toUtc().toIso8601String();

/// What the survey screen saves.
class SurveyInput {
  const SurveyInput({
    required this.roof,
    required this.layout,
    this.roofType,
    this.floors,
    this.orientationDeg = 180,
    this.tiltDeg,
    this.shading = ShadingLevel.none,
    this.notes = '',
  });

  final List<LatLng> roof;
  final PanelLayout layout;
  final RoofType? roofType;
  final int? floors;
  final int orientationDeg;
  final int? tiltDeg;
  final ShadingLevel shading;
  final String notes;
}

class SurveyRepository {
  SurveyRepository(this._db, this._photos);

  final PowerSyncDatabase _db;
  final AttachmentQueue _photos;

  Stream<Site?> watchSite(String leadId) => _db
      .watch(
        'SELECT * FROM sites WHERE lead_id = ? AND deleted_at IS NULL '
        'ORDER BY updated_at DESC LIMIT 1',
        parameters: [leadId],
      )
      .map((rows) => rows.isEmpty ? null : Site.fromRow(rows.first));

  /// Panel-fitting settings from `app_config` (company row wins) and the
  /// watt peak of the first active DCR panel in the catalogue.
  /// Saves a location found from the typed address (or a search) on a lead
  /// that had no GPS point.
  Future<void> setLeadLocation(String leadId, double lat, double lng) =>
      _db.execute(
        'UPDATE leads SET lat = ?, lng = ?, updated_at = ? WHERE id = ?',
        [lat, lng, _now(), leadId],
      );

  Future<SurveyConfig?> loadConfig(String companyId) async {
    final rows = await _db.getAll(
      'SELECT key, company_id, value FROM app_config WHERE key IN '
      "('panel_length_m', 'panel_width_m', 'panel_gap_m', 'roof_setback_m', "
      "'sqm_per_kw', 'default_panel_wp')",
    );
    final values = <String, Object?>{};
    for (final r in rows.where((r) => r['company_id'] == null)) {
      values[r['key']! as String] = jsonDecode(r['value']! as String);
    }
    for (final r in rows.where((r) => r['company_id'] == companyId)) {
      values[r['key']! as String] = jsonDecode(r['value']! as String);
    }
    final panel = await _db.getOptional(
      'SELECT watt_peak, length_m, width_m FROM products WHERE type = ? AND active = 1 '
      'AND deleted_at IS NULL AND watt_peak IS NOT NULL '
      'ORDER BY is_dcr DESC, almm_listed DESC LIMIT 1',
      ['panel'],
    );
    final wp =
        (panel?['watt_peak'] as num?)?.toDouble() ??
        (values['default_panel_wp'] as num?)?.toDouble();
    if (wp == null) return null;
    // The chosen panel's own size beats the generic default.
    final length = panel?['length_m'] as num?;
    final width = panel?['width_m'] as num?;
    if (length != null && width != null) {
      values['panel_length_m'] = length;
      values['panel_width_m'] = width;
    }
    try {
      return SurveyConfig.fromMap(values, panelWattPeak: wp);
    } on FormatException {
      return null; // not synced yet
    }
  }

  /// Saves the survey (one per lead) with the layout image, and moves a new
  /// lead to "surveyed".
  Future<void> saveSurvey({
    required String leadId,
    required String companyId,
    required String userId,
    required SurveyInput input,
    Site? existing,
    Uint8List? layoutPng,
  }) async {
    String? layoutPhotoId = existing?.layoutPhotoId;
    if (layoutPng != null) {
      final att = await _photos.saveFile(
        data: Stream.value(layoutPng),
        mediaType: 'image/png',
        fileExtension: 'png',
        metaData: companyId,
        updateHook: (tx, a) async {
          await tx.execute(
            'INSERT INTO $leadPhotosTable '
            '(id, company_id, lead_id, kind, created_by, created_at) '
            "VALUES (?, ?, ?, 'roof_layout', ?, ?)",
            [a.id, companyId, leadId, userId, _now()],
          );
          if (existing?.layoutPhotoId != null) {
            await tx.execute(
              'UPDATE $leadPhotosTable SET deleted_at = ? WHERE id = ?',
              [_now(), existing!.layoutPhotoId],
            );
          }
        },
      );
      layoutPhotoId = att.id;
    }

    final fields = <String, Object?>{
      'roof_type': input.roofType?.dbValue,
      'floors': input.floors,
      'roof_polygons': polygonToGeoJson(input.roof),
      'usable_area_sqm': double.parse(input.layout.areaSqm.toStringAsFixed(1)),
      'orientation_deg': input.orientationDeg % 360,
      'tilt_deg': input.tiltDeg,
      'shading_level': input.shading.name,
      'fitted_panel_count': input.layout.panelCount,
      'fitted_kw': double.parse(input.layout.fittedKw.toStringAsFixed(2)),
      'max_kw': double.parse(input.layout.roofLimitKw.toStringAsFixed(2)),
      'layout_photo_id': layoutPhotoId,
      'notes': input.notes.trim().isEmpty ? null : input.notes.trim(),
      'surveyed_by': userId,
      'updated_at': _now(),
    };
    await _db.writeTransaction((tx) async {
      if (existing != null) {
        await tx.execute(
          'UPDATE sites SET ${fields.keys.map((k) => '$k = ?').join(', ')} '
          'WHERE id = ?',
          [...fields.values, existing.id],
        );
      } else {
        final all = {
          ...fields,
          'id': _uuid.v4(),
          'company_id': companyId,
          'lead_id': leadId,
          'created_at': _now(),
        };
        await tx.execute(
          'INSERT INTO sites (${all.keys.join(', ')}) '
          'VALUES (${List.filled(all.length, '?').join(', ')})',
          all.values.toList(),
        );
      }
      await tx.execute(
        "UPDATE leads SET status = 'surveyed', updated_at = ? "
        "WHERE id = ? AND status = 'new'",
        [_now(), leadId],
      );
    });
  }
}

@Riverpod(keepAlive: true)
SurveyRepository surveyRepository(Ref ref) => SurveyRepository(
  ref.watch(powerSyncDbProvider),
  ref.watch(photoQueueProvider),
);

@riverpod
Stream<Site?> leadSite(Ref ref, String leadId) =>
    ref.watch(surveyRepositoryProvider).watchSite(leadId);
