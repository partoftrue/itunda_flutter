import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/neighborhood_provider.dart';
import '../../../core/services/location_service.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'location_map_view.dart';
import 'location_settings.dart';

class LocationModel {
  final String id;
  final String name;
  final String? district;
  final String? city;
  final double? latitude;
  final double? longitude;
  
  const LocationModel({
    required this.id,
    required this.name,
    this.district,
    this.city,
    this.latitude,
    this.longitude,
  });
  
  String get fullName {
    if (district != null && city != null) {
      return '$city $district $name';
    } else if (district != null) {
      return '$district $name';
    }
    return name;
  }
  
  String get shortName {
    // Return only the name without the district
    return name;
  }
  
  // Factory constructor to create from LocationData
  factory LocationModel.fromLocationData(LocationData data) {
    String id = '${data.latitude}_${data.longitude}';
    
    return LocationModel(
      id: id,
      name: data.neighborhood ?? '지역 불명',
      district: data.district,
      city: data.city,
      latitude: data.latitude,
      longitude: data.longitude,
    );
  }
}

class LocationSelector extends StatefulWidget {
  const LocationSelector({super.key});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> with SingleTickerProviderStateMixin {
  // Default locations (fallback)
  final List<LocationModel> _defaultLocations = const [
    LocationModel(
      id: 'gangnam_yeoksam',
      name: '역삼동',
      district: '강남구',
      city: '서울특별시',
    ),
    LocationModel(
      id: 'gangnam_samsung',
      name: '삼성동',
      district: '강남구',
      city: '서울특별시',
    ),
    LocationModel(
      id: 'gangnam_apgujeong',
      name: '압구정동',
      district: '강남구',
      city: '서울특별시',
    ),
    LocationModel(
      id: 'seocho_banpo',
      name: '반포동',
      district: '서초구',
      city: '서울특별시',
    ),
    LocationModel(
      id: 'seocho_seocho',
      name: '서초동',
      district: '서초구',
      city: '서울특별시',
    ),
    LocationModel(
      id: 'seongdong_seongsu',
      name: '성수동',
      district: '성동구',
      city: '서울특별시',
    ),
  ];
  
  List<LocationModel> _locations = [];
  late LocationModel _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _filteredLocations = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  
  // Tabs controller
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    // Initialize with default locations
    _locations = List.from(_defaultLocations);
    _selectedLocation = _locations[0];
    _filteredLocations = _locations;
    
    _searchController.addListener(() {
      _filterLocations();
    });
    
    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
    
    // Fetch current location after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }
  
  Future<void> _getCurrentLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // First initialize the service
      await locationService.init();
      
      if (locationService.permissionStatus == geo.LocationPermission.whileInUse || 
          locationService.permissionStatus == geo.LocationPermission.always) {
        
        // Get current location
        final locationData = await locationService.getCurrentLocation();
        
        if (locationData != null) {
          final currentLocation = LocationModel.fromLocationData(locationData);
          
          setState(() {
            // Add to the top of the list if not already present
            if (!_locations.any((loc) => loc.id == currentLocation.id)) {
              _locations.insert(0, currentLocation);
            }
            
            // Update selected location to current one
            _selectedLocation = currentLocation;
            _filteredLocations = _locations;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get your location: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _locations;
        _isSearching = false;
      } else {
        _filteredLocations = _locations.where((location) {
          return location.fullName.toLowerCase().contains(query);
        }).toList();
        _isSearching = true;
      }
    });
    
    // If search has more than 2 characters, search for locations
    if (query.length > 2) {
      _searchLocations(query);
    }
  }
  
  Future<void> _searchLocations(String query) async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final results = await locationService.searchLocations(query);
      
      List<LocationModel> searchResults = results
          .map((data) => LocationModel.fromLocationData(data))
          .toList();
      
      setState(() {
        // Only show search results if still searching
        if (_isSearching) {
          _filteredLocations = [
            ..._filteredLocations,
            ...searchResults.where(
              (result) => !_filteredLocations.any((loc) => loc.id == result.id)
            )
          ];
        }
      });
    } catch (e) {
      // Ignore search errors
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _selectLocation(LocationModel location) {
    final provider = Provider.of<NeighborhoodProvider>(context, listen: false);
    
    // Format location string with district if available
    String locationStr;
    if (location.district != null) {
      locationStr = '${location.district} ${location.name}';
    } else {
      locationStr = location.name;
    }
    
    provider.setCurrentLocation(locationStr);
    Navigator.pop(context);
  }
  
  void _closeSelector() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Handle bar and close button
          SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Title
                Text(
                  '내 동네 설정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                
                // Close button
                Positioned(
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onBackground,
                    ),
                    onPressed: _closeSelector,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onBackground.withOpacity(0.6),
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.list_alt),
                text: '목록',
              ),
              Tab(
                icon: Icon(Icons.map),
                text: '지도',
              ),
            ],
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(theme),
                LocationMapView(
                  onLocationSelected: _closeSelector,
                ),
              ],
            ),
          ),
          
          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
          
          // Location settings link
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('위치 정확도 및 옵션 설정'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListView(ThemeData theme) {
    return Column(
      children: [
        // Get my location button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.my_location_rounded, size: 18),
            label: const Text('내 위치 사용하기'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: theme.colorScheme.primary,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '동명(읍, 면)으로 검색',
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        // Error message if any
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        // Loading indicator
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        
        // Location list
        Expanded(
          child: ListView.builder(
            itemCount: _filteredLocations.length,
            itemBuilder: (context, index) {
              final location = _filteredLocations[index];
              final isSelected = _selectedLocation.id == location.id;
              
              return ListTile(
                onTap: () => _selectLocation(location),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                title: Text(
                  location.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                subtitle: Text(
                  [
                    if (location.district != null) location.district,
                    if (location.city != null) location.city,
                  ].where((s) => s != null).join(', '),
                  style: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              );
            },
          ),
        ),
        
        // Help text
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '현재 위치를 중심으로 근처 동네가 자동으로 설정됩니다.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onBackground.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
} 