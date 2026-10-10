import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/env.dart';

part 'google_tiles.g.dart';

final _log = Logger('GoogleTiles');

/// Google satellite tiles (Map Tiles API). A session token is created once
/// and lasts about two weeks; without a key or on failure the survey falls
/// back to Esri imagery.
class GoogleTiles {
  const GoogleTiles(this.session, this.key);

  final String session;
  final String key;

  String get urlTemplate =>
      'https://tile.googleapis.com/v1/2dtiles/{z}/{x}/{y}?session=$session&key=$key';

  /// Google's required attribution for what is on screen.
  Future<String?> copyright(LatLngBounds b, int zoom) async {
    try {
      final uri = Uri.https('tile.googleapis.com', '/tile/v1/viewport', {
        'session': session,
        'key': key,
        'zoom': '$zoom',
        'north': '${b.north}',
        'south': '${b.south}',
        'east': '${b.east}',
        'west': '${b.west}',
      });
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;
      return (jsonDecode(res.body) as Map)['copyright'] as String?;
    } catch (_) {
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
Future<GoogleTiles?> googleTiles(Ref ref) async {
  final key = Env.mapsApiKey;
  if (key.isEmpty) return null;
  try {
    final res = await http.post(
      Uri.https('tile.googleapis.com', '/v1/createSession', {'key': key}),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mapType': 'satellite',
        'language': 'en-IN',
        'region': 'IN',
      }),
    );
    if (res.statusCode != 200) {
      _log.warning('Map Tiles session failed: ${res.statusCode} ${res.body}');
      return null;
    }
    final session = (jsonDecode(res.body) as Map)['session'] as String?;
    return session == null ? null : GoogleTiles(session, key);
  } catch (e) {
    _log.warning('Map Tiles session failed: $e');
    return null;
  }
}
