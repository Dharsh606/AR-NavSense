import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/navigation_models.dart';

class NavigationApiService {
  static const _openRouteApiKey = String.fromEnvironment('OPENROUTE_API_KEY');
  static const _userAgent = 'AR-NavSense/1.0 accessibility-navigation';

  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '6',
      'addressdetails': '1',
    });
    final response = await http.get(uri, headers: {'User-Agent': _userAgent});
    if (response.statusCode != 200) {
      throw Exception('Could not search OpenStreetMap places.');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      final displayName = map['display_name'] as String? ?? 'Unknown place';
      return PlaceSuggestion(
        name: (map['name'] as String?) ?? displayName.split(',').first,
        displayName: displayName,
        latitude: double.parse(map['lat'] as String),
        longitude: double.parse(map['lon'] as String),
      );
    }).toList();
  }

  Future<NavigationRoute> walkingRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    if (_openRouteApiKey.isEmpty) {
      throw Exception(
        'OpenRouteService key missing. Build with --dart-define=OPENROUTE_API_KEY=your_key.',
      );
    }

    final uri = Uri.https(
      'api.openrouteservice.org',
      '/v2/directions/foot-walking/geojson',
    );
    final body = jsonEncode({
      'coordinates': [
        [startLongitude, startLatitude],
        [endLongitude, endLatitude],
      ],
      'instructions': true,
    });

    final response = await http.post(
      uri,
      headers: {
        'Authorization': _openRouteApiKey,
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('OpenRouteService route failed: ${response.statusCode}.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final feature = (json['features'] as List<dynamic>).first as Map<String, dynamic>;
    final properties = feature['properties'] as Map<String, dynamic>;
    final summary = properties['summary'] as Map<String, dynamic>;
    final segments = properties['segments'] as List<dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    final points = coordinates.map((point) {
      final coord = point as List<dynamic>;
      return RoutePoint(
        latitude: (coord[1] as num).toDouble(),
        longitude: (coord[0] as num).toDouble(),
      );
    }).toList();

    final steps = <RouteStep>[];
    for (final segment in segments) {
      final segmentMap = segment as Map<String, dynamic>;
      final rawSteps = segmentMap['steps'] as List<dynamic>? ?? [];
      for (final rawStep in rawSteps) {
        final step = rawStep as Map<String, dynamic>;
        steps.add(
          RouteStep(
            instruction: step['instruction'] as String? ?? 'Continue',
            distanceMeters: (step['distance'] as num? ?? 0).toDouble(),
            durationSeconds: (step['duration'] as num? ?? 0).toDouble(),
          ),
        );
      }
    }

    return NavigationRoute(
      points: points,
      steps: steps,
      distanceMeters: (summary['distance'] as num).toDouble(),
      durationSeconds: (summary['duration'] as num).toDouble(),
    );
  }
}
