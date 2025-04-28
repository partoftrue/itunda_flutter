import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:provider/provider.dart';
import '../../../core/services/location_service.dart';
import '../presentation/providers/neighborhood_provider.dart';
import 'dart:async';

class LocationMapView extends StatefulWidget {
  final VoidCallback? onLocationSelected;
  
  const LocationMapView({
    super.key,
    this.onLocationSelected,
  });

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {
  bool _isLoading = true;
  String? _errorMessage;
  LocationData? _currentLocation;
  Timer? _loadingTimer;
  bool _showPermissionRequest = false;
  
  @override
  void initState() {
    super.initState();
    
    // Set a timeout for loading
    _loadingTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '위치 정보를 가져오는데 시간이 오래 걸립니다. 네트워크 연결을 확인해주세요.';
        });
      }
    });
    
    // Initialize location service after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initLocationService();
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _initLocationService() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showPermissionRequest = false;
    });
    
    try {
      // Check if already initialized
      if (locationService.currentLocation != null) {
        setState(() {
          _currentLocation = locationService.currentLocation;
          _isLoading = false;
        });
        return;
      }
      
      // Initialize location service
      await locationService.init();
      
      // Handle permission status
      if (locationService.permissionStatus == geo.LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _showPermissionRequest = true;
          _errorMessage = '위치 서비스를 사용하기 위해서는 권한이 필요합니다.';
        });
        return;
      } else if (locationService.permissionStatus == geo.LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage = '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.';
        });
        return;
      }
      
      // Get current location
      final locationData = await locationService.getCurrentLocation();
      
      if (mounted) {
        setState(() {
          _currentLocation = locationData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '위치 정보를 가져오는데 실패했습니다: $e';
        });
      }
    }
  }
  
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final permission = await geo.Geolocator.requestPermission();
      
      if (permission == geo.LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _errorMessage = '위치 권한이 거부되었습니다.';
        });
      } else if (permission == geo.LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _errorMessage = '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.';
        });
      } else {
        // Permission granted, get location
        await _initLocationService();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '권한 요청 중 오류가 발생했습니다: $e';
      });
    }
  }
  
  void _useCurrentLocation() {
    if (_currentLocation != null) {
      final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
      String locationName = '${_currentLocation!.district ?? ''} ${_currentLocation!.neighborhood ?? ''}';
      locationName = locationName.trim();
      
      if (locationName.isNotEmpty) {
        provider.setCurrentLocation(locationName);
        provider.showToast('현재 위치로 설정되었습니다: $locationName');
        
        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!();
        }
      }
    }
  }
  
  void _openAppSettings() async {
    await geo.Geolocator.openAppSettings();
  }
  
  void _openLocationSettings() async {
    await geo.Geolocator.openLocationSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return _buildLoadingState(theme);
    }
    
    if (_showPermissionRequest) {
      return _buildPermissionRequest(theme);
    }
    
    if (_errorMessage != null) {
      return _buildErrorState(theme);
    }
    
    if (_currentLocation == null) {
      return _buildNoLocationState(theme);
    }
    
    return _buildLocationDisplay(theme);
  }
  
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '위치 정보를 가져오는 중...',
            style: TextStyle(
              color: theme.colorScheme.onBackground,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionRequest(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            '위치 권한이 필요합니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '가까운 동네 게시물을 보기 위해 위치 정보 접근 권한이 필요합니다. 권한을 허용하시겠습니까?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _requestLocationPermission,
            icon: const Icon(Icons.location_on),
            label: const Text('위치 권한 허용하기'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _showPermissionRequest = false;
                _errorMessage = '위치 권한 없이 계속합니다. 기본 위치가 사용됩니다.';
              });
            },
            child: Text(
              '위치 권한 없이 계속하기',
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            '위치 정보를 가져올 수 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? '알 수 없는 오류가 발생했습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _initLocationService,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _openLocationSettings,
                icon: const Icon(Icons.settings_outlined, size: 16),
                label: const Text('위치 설정'),
              ),
              TextButton.icon(
                onPressed: _openAppSettings,
                icon: const Icon(Icons.app_settings_alt_outlined, size: 16),
                label: const Text('앱 설정'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoLocationState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_searching,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            '위치 정보가 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '현재 위치 정보를 찾을 수 없습니다. 위치 서비스가 활성화되어 있는지 확인해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _initLocationService,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationDisplay(ThemeData theme) {
    if (_currentLocation == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simple map-like visualization
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _currentLocation!.neighborhood ?? '현재 위치',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    onPressed: _initLocationService,
                    icon: const Icon(Icons.refresh),
                    color: theme.colorScheme.primary,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Text(
                    '정확도: 약 50m',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Location details
          Card(
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 위치 정보',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLocationInfoRow(
                    theme,
                    '동네',
                    _currentLocation!.neighborhood ?? '알 수 없음',
                  ),
                  const Divider(height: 24),
                  _buildLocationInfoRow(
                    theme,
                    '구',
                    _currentLocation!.district ?? '알 수 없음',
                  ),
                  const Divider(height: 24),
                  _buildLocationInfoRow(
                    theme,
                    '시/도',
                    _currentLocation!.city ?? '알 수 없음',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('이 위치로 설정하기'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: theme.colorScheme.primary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationInfoRow(ThemeData theme, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ],
    );
  }
} 