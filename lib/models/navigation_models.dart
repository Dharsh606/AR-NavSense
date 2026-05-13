class PlaceSuggestion {
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;

  const PlaceSuggestion({
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

class RoutePoint {
  final double latitude;
  final double longitude;

  const RoutePoint({required this.latitude, required this.longitude});
}

class RouteStep {
  final String instruction;
  final double distanceMeters;
  final double durationSeconds;
  final int? startPointIndex;
  final int? endPointIndex;

  const RouteStep({
    required this.instruction,
    required this.distanceMeters,
    required this.durationSeconds,
    this.startPointIndex,
    this.endPointIndex,
  });
}

class NavigationRoute {
  final List<RoutePoint> points;
  final List<RouteStep> steps;
  final double distanceMeters;
  final double durationSeconds;

  const NavigationRoute({
    required this.points,
    required this.steps,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}
