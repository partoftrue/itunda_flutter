import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'neighborhood_screen.dart';
import 'presentation/providers/neighborhood_provider.dart';
import 'widgets/neighborhood_toast.dart';
import '../../core/services/location_service.dart';

class NeighborhoodFeature extends StatefulWidget {
  const NeighborhoodFeature({super.key});

  @override
  State<NeighborhoodFeature> createState() => _NeighborhoodFeatureState();
}

class _NeighborhoodFeatureState extends State<NeighborhoodFeature> {
  @override
  void initState() {
    super.initState();
    // Initialize location service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initLocationService();
      }
    });
  }

  Future<void> _initLocationService() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    await locationService.init();
    
    // Make sure widget is still mounted before continuing
    if (!mounted) return;
    
    // Show toast with location status message
    final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
    
    if (locationService.permissionStatus == geo.LocationPermission.denied) {
      provider.showToast('위치 권한이 없습니다. 설정에서 위치 권한을 허용해주세요.');
    } else if (locationService.permissionStatus == geo.LocationPermission.deniedForever) {
      provider.showToast('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    } else if (locationService.currentLocation != null) {
      final locationData = locationService.currentLocation!;
      String locationName = '${locationData.district ?? ''} ${locationData.neighborhood ?? ''}';
      locationName = locationName.trim();
      
      if (locationName.isNotEmpty) {
        provider.setCurrentLocation(locationName);
      }
      
      // Start location updates
      locationService.startLocationUpdates();
      
      // Subscribe to location updates with better stream management
      final subscription = locationService.locationUpdates.listen((locationData) {
        if (!mounted) return;
        
        String locationName = '${locationData.district ?? ''} ${locationData.neighborhood ?? ''}';
        locationName = locationName.trim();
        
        if (locationName.isNotEmpty) {
          provider.setCurrentLocation(locationName);
        }
      });
      
      // Store subscription for disposal when widget is unmounted
      _locationSubscription = subscription;
    }
  }
  
  // Stream subscription to manage
  StreamSubscription? _locationSubscription;
  
  @override
  void dispose() {
    // Cancel stream subscription
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<LocationService, NeighborhoodProvider>(
      create: (context) => NeighborhoodProvider(),
      update: (context, locationService, previousProvider) {
        if (previousProvider == null) {
          return NeighborhoodProvider();
        }
        
        // Update the provider with the current location if needed
        if (locationService.currentLocation != null) {
          String locationName = '${locationService.currentLocation!.district ?? ''} ${locationService.currentLocation!.neighborhood ?? ''}';
          locationName = locationName.trim();
          
          if (locationName.isNotEmpty && locationName != previousProvider.currentLocation) {
            previousProvider.setCurrentLocation(locationName);
          }
        }
        
        return previousProvider;
      },
      child: const NeighborhoodToast(
        child: NeighborhoodScreen(),
      ),
    );
  }
} 