import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_core/solar_core.dart';
import 'package:uuid/uuid.dart';

import '../../../core/format/indian_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/empty_state.dart';
import '../../leads/application/leads_providers.dart';
import '../../leads/domain/lead.dart';
import '../data/google_tiles.dart';
import '../data/maps_api.dart';
import '../data/survey_repository.dart';
import '../domain/roof_geometry.dart';
import '../domain/site.dart';

part 'survey_screen.g.dart';

/// Satellite tiles on/off (widget tests turn them off: no network).
@Riverpod(keepAlive: true)
bool satelliteTiles(Ref ref) => true;

const _esriImagery =
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

String directionLabel(AppLocalizations l10n, int deg) =>
    switch (compassPoint(deg)) {
      'N' => l10n.dirN,
      'NE' => l10n.dirNE,
      'E' => l10n.dirE,
      'SE' => l10n.dirSE,
      'S' => l10n.dirS,
      'SW' => l10n.dirSW,
      'W' => l10n.dirW,
      _ => l10n.dirNW,
    };

/// Roof survey: draw the roof on satellite imagery, see the area and the
/// panels that fit, record roof type, orientation, tilt and shading.
class SurveyScreen extends ConsumerWidget {
  const SurveyScreen({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lead = ref.watch(leadProvider(leadId)).value;
    final site = ref.watch(leadSiteProvider(leadId));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lead == null
              ? l10n.surveyTitle
              : '${l10n.surveyTitle} · ${lead.name}',
        ),
      ),
      body: lead == null || !site.hasValue
          ? const Center(child: CircularProgressIndicator())
          : _SurveyBody(lead: lead, site: site.value),
    );
  }
}

class _SurveyBody extends ConsumerStatefulWidget {
  const _SurveyBody({required this.lead, required this.site});

  final Lead lead;
  final Site? site;

  @override
  ConsumerState<_SurveyBody> createState() => _SurveyBodyState();
}

class _SurveyBodyState extends ConsumerState<_SurveyBody> {
  final _map = MapController();
  final _boundary = GlobalKey();
  late final _notes = TextEditingController(text: widget.site?.notes);
  late List<LatLng> _points = [...?widget.site?.roof];
  late RoofType? _roofType = widget.site?.roofType;
  late int _floors = widget.site?.floors ?? 1;
  late int _orientation = widget.site?.orientationDeg ?? 180;
  late int _tilt =
      widget.site?.tiltDeg ??
      (widget.lead.lat?.abs().round().clamp(10, 30) ?? 20);
  late ShadingLevel _shading = widget.site?.shading ?? ShadingLevel.none;
  SurveyConfig? _config;
  bool _configMissing = false;
  bool _saving = false;

  // Address search (Places), Google roof detection and imagery credits.
  final _search = TextEditingController();
  String _session = const Uuid().v4();
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = const [];
  bool _mapReady = false;
  LatLng? _pendingMove;
  bool _detecting = false;
  SolarInsights? _google;
  String? _copyright;
  Timer? _copyrightDebounce;

  LatLng? get _center => widget.lead.hasLocation
      ? LatLng(widget.lead.lat!, widget.lead.lng!)
      : (_points.isNotEmpty ? _points.first : null);

  String get _leadAddress =>
      [widget.lead.address, widget.lead.district, widget.lead.pincode]
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .join(', ');

  void _moveTo(LatLng p, {double zoom = 19.5}) {
    if (_mapReady) {
      _map.move(p, zoom);
    } else {
      _pendingMove = p;
    }
  }

  void _toast(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  /// A lead typed in without GPS: find the address on the map.
  Future<void> _locateAddress() async {
    final address = _leadAddress;
    if (address.isEmpty) return;
    final l10n = context.l10n;
    try {
      final hit = await ref.read(mapsApiProvider).geocode(address);
      if (!mounted) return;
      if (hit == null) {
        _toast(l10n.addressNotFound);
        return;
      }
      _moveTo(hit.point, zoom: 18.5);
      await ref
          .read(surveyRepositoryProvider)
          .setLeadLocation(
            widget.lead.id,
            hit.point.latitude,
            hit.point.longitude,
          );
      _toast(l10n.addressLocated);
    } catch (_) {
      // Offline: the rep can still search or use My location later.
    }
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    if (text.trim().length < 3) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        final s = await ref.read(mapsApiProvider).autocomplete(text, _session);
        if (mounted) setState(() => _suggestions = s);
      } catch (_) {
        if (mounted) setState(() => _suggestions = const []);
      }
    });
  }

  Future<void> _pickSuggestion(PlaceSuggestion s) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = const [];
      _search.text = s.text;
    });
    try {
      final hit = await ref.read(mapsApiProvider).place(s.placeId, _session);
      _session = const Uuid().v4(); // a session ends with the place lookup
      if (hit == null) return;
      _moveTo(hit.point);
      if (!widget.lead.hasLocation) {
        await ref
            .read(surveyRepositoryProvider)
            .setLeadLocation(
              widget.lead.id,
              hit.point.latitude,
              hit.point.longitude,
            );
      }
    } catch (e) {
      if (mounted) _toast(describeError(context.l10n, e));
    }
  }

  /// Google Solar API: outline, direction and shade of the roof under the
  /// map centre. The rep checks and adjusts the corners.
  Future<void> _detectRoof() async {
    final l10n = context.l10n;
    setState(() => _detecting = true);
    try {
      final at = _mapReady
          ? _map.camera.center
          : (_center ?? const LatLng(22.5, 79));
      final g = await ref.read(mapsApiProvider).solar(at);
      if (!mounted) return;
      final outline = g?.outline;
      if (g == null || outline == null) {
        _toast(l10n.roofNotFound);
        return;
      }
      setState(() {
        _google = g;
        _points = outline;
        _orientation = g.orientationDeg ?? _orientation;
        _shading = switch (g.shading) {
          'none' => ShadingLevel.none,
          'low' => ShadingLevel.low,
          'medium' => ShadingLevel.medium,
          'high' => ShadingLevel.high,
          _ => _shading,
        };
      });
      if (_mapReady) {
        _map.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(outline),
            padding: const EdgeInsets.all(48),
            maxZoom: 20.5,
          ),
        );
      }
      _toast(l10n.roofDetected);
    } catch (e) {
      if (mounted) _toast(describeError(l10n, e));
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  void _updateCopyright(GoogleTiles g) {
    _copyrightDebounce?.cancel();
    _copyrightDebounce = Timer(const Duration(milliseconds: 600), () async {
      if (!_mapReady) return;
      final c = await g.copyright(
        _map.camera.visibleBounds,
        _map.camera.zoom.round(),
      );
      if (mounted && c != null && c != _copyright) {
        setState(() => _copyright = c);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final member = ref.read(currentMemberProvider);
    if (member != null) {
      ref.read(surveyRepositoryProvider).loadConfig(member.company.id).then((
        c,
      ) {
        if (mounted) {
          setState(() {
            _config = c;
            _configMissing = c == null;
          });
        }
      });
    }
    if (!widget.lead.hasLocation && _points.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _locateAddress());
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    _search.dispose();
    _debounce?.cancel();
    _copyrightDebounce?.cancel();
    super.dispose();
  }

  PanelLayout? get _layout => _config == null || _points.length < 3
      ? null
      : fitPanels(_points, config: _config!);

  Future<void> _goToMyLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      _map.move(LatLng(pos.latitude, pos.longitude), 19.5);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.locationFailed)));
      }
    }
  }

  /// Fits the camera on the roof and snapshots the map with the panels.
  Future<Uint8List?> _captureLayout() async {
    if (_points.length < 3) return null;
    _map.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(_points),
        padding: const EdgeInsets.all(36),
        maxZoom: 21,
      ),
    );
    // Give the tiles a moment to draw at the new camera.
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final boundary =
        _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    try {
      final image = await boundary.toImage(pixelRatio: 1.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } catch (_) {
      return null; // e.g. tiles not capturable on this platform
    }
  }

  Future<void> _save() async {
    final member = ref.read(currentMemberProvider);
    final layout = _layout;
    if (member == null || layout == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      // No imagery (tiles off) means nothing worth capturing.
      final png = ref.read(satelliteTilesProvider)
          ? await _captureLayout()
          : null;
      await ref
          .read(surveyRepositoryProvider)
          .saveSurvey(
            leadId: widget.lead.id,
            companyId: member.company.id,
            userId: member.profile.id,
            existing: widget.site,
            layoutPng: png,
            input: SurveyInput(
              roof: _points,
              layout: layout,
              roofType: _roofType,
              floors: _floors,
              orientationDeg: _orientation,
              tiltDeg: _tilt,
              shading: _shading,
              notes: _notes.text,
            ),
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.surveySaved)));
      router.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e))));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final tiles = ref.watch(satelliteTilesProvider);
    final google = tiles ? ref.watch(googleTilesProvider).value : null;
    final layout = _layout;

    if (_configMissing) {
      return EmptyState(
        icon: Icons.cloud_sync_outlined,
        title: l10n.surveyConfigMissing,
      );
    }

    final map = Stack(
      children: [
        RepaintBoundary(
          key: _boundary,
          child: FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center ?? const LatLng(22.5, 79),
              initialZoom: _center == null ? 5 : 19.5,
              maxZoom: 21,
              onTap: (_, p) {
                FocusScope.of(context).unfocus();
                setState(() {
                  _suggestions = const [];
                  _points = [..._points, p];
                });
              },
              onMapReady: () {
                _mapReady = true;
                final p = _pendingMove;
                if (p != null) {
                  _pendingMove = null;
                  _map.move(p, 18.5);
                }
                if (google != null) _updateCopyright(google);
              },
              onMapEvent: (e) {
                if (google != null && e is MapEventMoveEnd) {
                  _updateCopyright(google);
                }
              },
            ),
            children: [
              if (tiles)
                TileLayer(
                  // Google when the key and Map Tiles API work, else Esri.
                  key: ValueKey(google?.session ?? 'esri'),
                  urlTemplate: google?.urlTemplate ?? _esriImagery,
                  maxNativeZoom: google != null ? 21 : 19,
                  maxZoom: 21,
                  userAgentPackageName: 'in.solarkatha.app',
                ),
              if (_points.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _points,
                      color: const Color(0x40E07B00),
                      borderColor: const Color(0xFFEA580C),
                      borderStrokeWidth: 3,
                    ),
                  ],
                ),
              if (layout != null)
                PolygonLayer(
                  polygons: [
                    for (final panel in layout.panels)
                      Polygon(
                        points: panel,
                        color: const Color(0xCC0D47A1),
                        borderColor: Colors.white,
                        borderStrokeWidth: 1,
                      ),
                  ],
                ),
              if (_points.length == 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _points,
                      color: const Color(0xFFEA580C),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (final p in _points)
                    Marker(
                      point: p,
                      width: 18,
                      height: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFEA580C),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (tiles)
                RichAttributionWidget(
                  alignment: AttributionAlignment.bottomLeft,
                  attributions: [
                    TextSourceAttribution(
                      google != null
                          ? (_copyright == null
                                ? 'Google'
                                : 'Google · $_copyright')
                          : 'Esri, Maxar, Earthstar Geographics',
                    ),
                  ],
                ),
            ],
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          top: 8,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const Key('survey.search'),
                    controller: _search,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.searchPlaceHint,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  for (final sug in _suggestions)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined, size: 20),
                      title: Text(
                        sug.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _pickSuggestion(sug),
                    ),
                  if (_suggestions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                      child: Row(
                        children: [
                          const Icon(Icons.touch_app_outlined, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _center == null
                                  ? l10n.noLocationHint
                                  : l10n.drawRoofHint,
                              style: theme.textTheme.bodySmall,
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
        Positioned(
          right: 8,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'loc',
                tooltip: l10n.myLocation,
                onPressed: _goToMyLocation,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                key: const Key('survey.undo'),
                heroTag: 'undo',
                tooltip: l10n.undoPoint,
                onPressed: _points.isEmpty
                    ? null
                    : () => setState(
                        () => _points = _points.sublist(0, _points.length - 1),
                      ),
                child: const Icon(Icons.undo),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'clear',
                tooltip: l10n.clearRoof,
                onPressed: _points.isEmpty
                    ? null
                    : () => setState(() => _points = []),
                child: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
    );

    Widget stat(String label, String value, {Key? key}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          Text(
            value,
            key: key,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final panel = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          key: const Key('survey.detect'),
          onPressed: _detecting ? null : _detectRoof,
          icon: _detecting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(l10n.detectRoof),
        ),
        if (_google case final g?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.googleRoofInfo(
                (g.maxPanels ?? '-').toString(),
                IndianFormat.number(
                  (g.maxSunshineHours ?? 0).round(),
                  languageCode: lang,
                ),
                g.imageryDate ?? '-',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 16),
        if (layout == null)
          Text(l10n.needThreePoints, style: theme.textTheme.bodyLarge)
        else ...[
          Row(
            children: [
              stat(
                l10n.roofAreaResult,
                '${IndianFormat.number(layout.areaSqm.round(), languageCode: lang)} m²',
                key: const Key('survey.area'),
              ),
              stat(
                l10n.panelsFit,
                '${layout.panelCount}',
                key: const Key('survey.panels'),
              ),
              stat(
                l10n.fittedKwLabel,
                IndianFormat.kw(layout.fittedKw, languageCode: lang),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.maxKwRoof(
              IndianFormat.kw(layout.roofLimitKw, languageCode: lang),
            ),
            key: const Key('survey.maxKw'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        const Divider(height: 32),
        Text(l10n.roofTypeLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        SegmentedButton<RoofType>(
          emptySelectionAllowed: true,
          segments: [
            ButtonSegment(value: RoofType.rcc, label: Text(l10n.roofRcc)),
            ButtonSegment(value: RoofType.tinSheet, label: Text(l10n.roofTin)),
            ButtonSegment(value: RoofType.other, label: Text(l10n.roofOther)),
          ],
          selected: {?_roofType},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _roofType = s.firstOrNull),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(l10n.floorsLabel, style: theme.textTheme.labelLarge),
            ),
            IconButton.outlined(
              onPressed: _floors > 0 ? () => setState(() => _floors--) : null,
              icon: const Icon(Icons.remove),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('$_floors', style: theme.textTheme.titleMedium),
            ),
            IconButton.outlined(
              onPressed: () => setState(() => _floors++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${l10n.orientationLabel}: ${directionLabel(l10n, _orientation)} '
          '(${l10n.degreesValue('$_orientation')})',
          style: theme.textTheme.labelLarge,
        ),
        Slider(
          value: _orientation.toDouble(),
          max: 345,
          divisions: 23,
          label: directionLabel(l10n, _orientation),
          onChanged: (v) => setState(() => _orientation = v.round()),
        ),
        Text(
          '${l10n.tiltLabel}: ${l10n.degreesValue('$_tilt')}',
          style: theme.textTheme.labelLarge,
        ),
        Slider(
          value: _tilt.toDouble(),
          max: 45,
          divisions: 45,
          label: l10n.degreesValue('$_tilt'),
          onChanged: (v) => setState(() => _tilt = v.round()),
        ),
        DropdownButtonFormField<ShadingLevel>(
          initialValue: _shading,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.shadingLabel),
          items: [
            for (final s in ShadingLevel.values)
              DropdownMenuItem(
                value: s,
                child: Text(switch (s) {
                  ShadingLevel.none => l10n.shadingNone,
                  ShadingLevel.low => l10n.shadingLow,
                  ShadingLevel.medium => l10n.shadingMedium,
                  ShadingLevel.high => l10n.shadingHigh,
                }),
              ),
          ],
          onChanged: (v) => setState(() => _shading = v!),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(labelText: l10n.leadNotesLabel),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('survey.save'),
          onPressed: _saving || layout == null ? null : _save,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(l10n.saveSurvey),
        ),
        const SizedBox(height: 24),
      ],
    );

    if (wide) {
      return Row(
        children: [
          Expanded(flex: 3, child: map),
          SizedBox(
            width: math.min(440, MediaQuery.sizeOf(context).width * 0.4),
            child: panel,
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(flex: 5, child: map),
        const Divider(height: 1),
        Expanded(flex: 4, child: panel),
      ],
    );
  }
}
