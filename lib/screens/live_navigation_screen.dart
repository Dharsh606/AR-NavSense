import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/navigation_models.dart';
import '../services/location_service.dart';
import '../services/navigation_api_service.dart';
import '../services/voice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class LiveNavigationScreen extends StatefulWidget {
  final PlaceSuggestion? destination;

  const LiveNavigationScreen({Key? key, this.destination}) : super(key: key);

  @override
  State<LiveNavigationScreen> createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {
  final _mapController = MapController();
  final _locationService = LocationService();
  final _navigationApi = NavigationApiService();
  final _voice = VoiceService();
  final _searchController = TextEditingController();

  StreamSubscription? _positionSub;
  LatLng? _current;
  PlaceSuggestion? _destination;
  NavigationRoute? _route;
  List<PlaceSuggestion> _suggestions = [];
  bool _loading = true;
  String? _status;

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _boot();
  }

  Future<void> _boot() async {
    await _voice.initialize();
    try {
      final position = await _locationService.currentPosition();
      setState(() {
        _current = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
      _positionSub = _locationService.positionStream().listen((position) {
        final next = LatLng(position.latitude, position.longitude);
        setState(() => _current = next);
        _mapController.move(next, _mapController.camera.zoom);
      });
      if (_destination != null) {
        await _startRoute(_destination!);
      } else {
        await _voice.speak('Live navigation is ready. Search or speak a destination.');
      }
    } catch (error) {
      setState(() {
        _loading = false;
        _status = error.toString();
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 3) return;
    setState(() => _status = 'Searching OpenStreetMap...');
    try {
      final places = await _navigationApi.searchPlaces(query);
      setState(() {
        _suggestions = places;
        _status = places.isEmpty ? 'No places found.' : null;
      });
    } catch (error) {
      setState(() => _status = error.toString());
    }
  }

  Future<void> _startRoute(PlaceSuggestion destination) async {
    final current = _current;
    if (current == null) return;
    setState(() {
      _loading = true;
      _destination = destination;
      _suggestions = [];
      _status = 'Generating real walking route...';
    });
    try {
      final route = await _navigationApi.walkingRoute(
        startLatitude: current.latitude,
        startLongitude: current.longitude,
        endLatitude: destination.latitude,
        endLongitude: destination.longitude,
      );
      setState(() {
        _route = route;
        _loading = false;
        _status = null;
      });
      if (route.points.isNotEmpty) {
        final firstStep = route.steps.isNotEmpty
            ? route.steps.first.instruction
            : 'Proceed toward ${destination.name}.';
        await _voice.speak(
          'Route ready to ${destination.name}. ${_formatDistance(route.distanceMeters)}, about ${_formatDuration(route.durationSeconds)}. $firstStep',
        );
      }
    } catch (error) {
      setState(() {
        _loading = false;
        _status = error.toString();
      });
      await _voice.speak('I could not create the route. ${error.toString()}');
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _current ?? const LatLng(20.5937, 78.9629);
    final routePoints = _route?.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList() ??
        <LatLng>[];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Live Navigation'), centerTitle: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: current,
              initialZoom: 16,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.arnavsense.ar_navsense',
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 7,
                      color: AppTheme.primaryGreen.withOpacity(0.85),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: current,
                    width: 54,
                    height: 54,
                    child: const _LocationPulse(),
                  ),
                  if (_destination != null)
                    Marker(
                      point: LatLng(_destination!.latitude, _destination!.longitude),
                      width: 54,
                      height: 54,
                      child: const Icon(Icons.flag_circle, color: AppTheme.accentBlue, size: 46),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: GlassmorphicContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    borderRadius: 24,
                    color: Colors.white,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _search,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                        hintText: 'Search destination with OpenStreetMap',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.near_me),
                          onPressed: () => _search(_searchController.text),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassmorphicContainer(
                      padding: const EdgeInsets.all(8),
                      color: Colors.white,
                      child: Column(
                        children: _suggestions
                            .map(
                              (place) => ListTile(
                                leading: const Icon(Icons.place, color: AppTheme.primaryGreen),
                                title: Text(
                                  place.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppTheme.textPrimary),
                                ),
                                subtitle: Text(
                                  place.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppTheme.textSecondary),
                                ),
                                onTap: () => _startRoute(place),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                const Spacer(),
                _NavigationSheet(
                  loading: _loading,
                  status: _status,
                  destination: _destination,
                  route: _route,
                  onSpeakNext: () {
                    final step = _route?.steps.isNotEmpty == true
                        ? _route!.steps.first.instruction
                        : 'No route step is available yet.';
                    _voice.speak(step);
                  },
                ).animate().fadeIn(duration: 400.ms).slideY(begin: .18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} kilometers';
    return '${meters.round()} meters';
  }

  String _formatDuration(double seconds) => '${(seconds / 60).round()} minutes';
}

class _NavigationSheet extends StatelessWidget {
  final bool loading;
  final String? status;
  final PlaceSuggestion? destination;
  final NavigationRoute? route;
  final VoidCallback onSpeakNext;

  const _NavigationSheet({
    required this.loading,
    required this.status,
    required this.destination,
    required this.route,
    required this.onSpeakNext,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      borderRadius: 28,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.assistant_navigation, color: AppTheme.primaryGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  destination?.name ?? 'Ready for destination',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
              if (loading)
                const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            status ??
                (route == null
                    ? 'Search a place to generate a live OpenRouteService walking route.'
                    : '${(route!.distanceMeters / 1000).toStringAsFixed(1)} km • ${(route!.durationSeconds / 60).round()} min'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (route?.steps.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Text(
              route!.steps.first.instruction,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSpeakNext,
                icon: const Icon(Icons.volume_up),
                label: const Text('Speak next guidance'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationPulse extends StatelessWidget {
  const _LocationPulse();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primaryGreen.withOpacity(.18),
        border: Border.all(color: AppTheme.primaryGreen, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.my_location, color: AppTheme.primaryGreen, size: 26),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).scale(
          begin: const Offset(.82, .82),
          end: const Offset(1.08, 1.08),
          duration: 1200.ms,
        );
  }
}
