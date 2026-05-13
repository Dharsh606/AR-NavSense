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
    if (_openRouteApiKey.isEmpty || _openRouteApiKey == 'demo') {
      return _osrmWalkingRoute(
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
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
      return _osrmWalkingRoute(
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
      );
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
        final rawWayPoints = step['way_points'] as List<dynamic>? ?? [];
        final wayPoints = rawWayPoints.map((point) => (point as num).toInt()).toList();
        steps.add(
          RouteStep(
            instruction: step['instruction'] as String? ?? 'Continue',
            distanceMeters: (step['distance'] as num? ?? 0).toDouble(),
            durationSeconds: (step['duration'] as num? ?? 0).toDouble(),
            startPointIndex: wayPoints.length >= 2 ? wayPoints.first : null,
            endPointIndex: wayPoints.length >= 2 ? wayPoints.last : null,
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

  Future<NavigationRoute> _osrmWalkingRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/foot/$startLongitude,$startLatitude;$endLongitude,$endLatitude',
      {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'true',
      },
    );
    final response = await http.get(uri, headers: {'User-Agent': _userAgent});
    if (response.statusCode != 200) {
      throw Exception('Walking route service failed: ${response.statusCode}.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = json['routes'] as List<dynamic>? ?? [];
    if (routes.isEmpty) {
      throw Exception('No walking route found for this destination.');
    }

    final routeJson = routes.first as Map<String, dynamic>;
    final geometry = routeJson['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final points = coordinates.map((point) {
      final coord = point as List<dynamic>;
      return RoutePoint(
        latitude: (coord[1] as num).toDouble(),
        longitude: (coord[0] as num).toDouble(),
      );
    }).toList();

    final steps = <RouteStep>[];
    final legs = routeJson['legs'] as List<dynamic>? ?? [];
    for (final leg in legs) {
      final legMap = leg as Map<String, dynamic>;
      final rawSteps = legMap['steps'] as List<dynamic>? ?? [];
      for (final rawStep in rawSteps) {
        final step = rawStep as Map<String, dynamic>;
        final maneuver = step['maneuver'] as Map<String, dynamic>? ?? {};
        final maneuverLocation = maneuver['location'] as List<dynamic>?;
        final startIndex = maneuverLocation == null
            ? null
            : _nearestPointIndex(
                points,
                (maneuverLocation[1] as num).toDouble(),
                (maneuverLocation[0] as num).toDouble(),
              );
        steps.add(
          RouteStep(
            instruction: _osrmInstruction(step),
            distanceMeters: (step['distance'] as num? ?? 0).toDouble(),
            durationSeconds: (step['duration'] as num? ?? 0).toDouble(),
            startPointIndex: startIndex,
          ),
        );
      }
    }

    for (var i = 0; i < steps.length; i++) {
      final current = steps[i];
      final nextStart = i + 1 < steps.length ? steps[i + 1].startPointIndex : points.length - 1;
      steps[i] = RouteStep(
        instruction: current.instruction,
        distanceMeters: current.distanceMeters,
        durationSeconds: current.durationSeconds,
        startPointIndex: current.startPointIndex,
        endPointIndex: nextStart,
      );
    }

    return NavigationRoute(
      points: points,
      steps: steps,
      distanceMeters: (routeJson['distance'] as num? ?? 0).toDouble(),
      durationSeconds: (routeJson['duration'] as num? ?? 0).toDouble(),
    );
  }

  String _osrmInstruction(Map<String, dynamic> step) {
    final name = (step['name'] as String? ?? '').trim();
    final maneuver = step['maneuver'] as Map<String, dynamic>? ?? {};
    final type = (maneuver['type'] as String? ?? 'continue').replaceAll('_', ' ');
    final modifier = maneuver['modifier'] as String?;

    if (type == 'arrive') return 'You have arrived at your destination.';
    if (type == 'depart') {
      return name.isEmpty ? 'Start walking.' : 'Start walking on $name.';
    }
    if (modifier == null || modifier.isEmpty) {
      return name.isEmpty ? 'Continue walking.' : 'Continue on $name.';
    }
    return name.isEmpty ? '${_capitalize(type)} $modifier.' : '${_capitalize(type)} $modifier onto $name.';
  }

  int _nearestPointIndex(List<RoutePoint> points, double latitude, double longitude) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final lat = point.latitude - latitude;
      final lon = point.longitude - longitude;
      final distance = lat * lat + lon * lon;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
