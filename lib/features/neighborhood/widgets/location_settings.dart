import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/location_service.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  late LocationAccuracy _selectedAccuracy;
  late bool _cacheEnabled;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize with current settings
    final locationService = Provider.of<LocationService>(context, listen: false);
    _selectedAccuracy = locationService.accuracy;
    _cacheEnabled = locationService.useCache;
  }
  
  void _updateAccuracy(LocationAccuracy? value) {
    if (value != null) {
      setState(() {
        _selectedAccuracy = value;
      });
      
      final locationService = Provider.of<LocationService>(context, listen: false);
      locationService.setAccuracy(value);
    }
  }
  
  void _updateCacheEnabled(bool? value) {
    if (value != null) {
      setState(() {
        _cacheEnabled = value;
      });
      
      final locationService = Provider.of<LocationService>(context, listen: false);
      locationService.setCacheEnabled(value);
    }
  }
  
  void _clearLocationCache() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    await locationService.clearCache();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위치 정보 캐시가 삭제되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  String _getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return '가장 낮음 (배터리 효율적, 정확도 낮음)';
      case LocationAccuracy.low:
        return '낮음 (배터리 효율적, 정확도 낮음)';
      case LocationAccuracy.medium:
        return '중간 (균형잡힌 정확도)';
      case LocationAccuracy.high:
        return '높음 (정확한 위치, 권장)';
      case LocationAccuracy.best:
        return '최상 (매우 정확한 위치, 배터리 소모 높음)';
      case LocationAccuracy.navigation:
        return '내비게이션 (가장 정확한 위치, 배터리 소모 매우 높음)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          
          // Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '위치 서비스 설정을 변경하여 배터리 사용량과 정확도를 조절할 수 있습니다.',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          
          // Accuracy settings
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '위치 정확도',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ),
                const Divider(height: 1),
                
                // Accuracy options
                _buildAccuracyOption(
                  theme,
                  LocationAccuracy.lowest,
                  '가장 낮음',
                  Icons.battery_full,
                ),
                const Divider(height: 1),
                _buildAccuracyOption(
                  theme,
                  LocationAccuracy.low,
                  '낮음',
                  Icons.battery_5_bar,
                ),
                const Divider(height: 1),
                _buildAccuracyOption(
                  theme,
                  LocationAccuracy.medium,
                  '중간',
                  Icons.battery_4_bar,
                ),
                const Divider(height: 1),
                _buildAccuracyOption(
                  theme,
                  LocationAccuracy.high,
                  '높음 (권장)',
                  Icons.battery_3_bar,
                ),
                const Divider(height: 1),
                _buildAccuracyOption(
                  theme,
                  LocationAccuracy.best,
                  '최상',
                  Icons.battery_2_bar,
                ),
                const Divider(height: 1),
                _buildAccuracyOption(
                  theme,
                  LocationAccuracy.navigation,
                  '내비게이션',
                  Icons.battery_1_bar,
                ),
              ],
            ),
          ),
          
          // Caching settings
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '위치 정보 캐싱',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('위치 정보 캐싱 사용'),
                  subtitle: const Text('앱 재시작시 마지막 위치 정보 사용'),
                  value: _cacheEnabled,
                  onChanged: _updateCacheEnabled,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('캐시 삭제'),
                  subtitle: const Text('저장된 위치 정보 삭제'),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: _clearLocationCache,
                ),
              ],
            ),
          ),
          
          // Cache expiration info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '위치 정보 캐시는 24시간 후 자동으로 만료됩니다.',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildAccuracyOption(
    ThemeData theme,
    LocationAccuracy accuracy,
    String title,
    IconData icon,
  ) {
    final isSelected = _selectedAccuracy == accuracy;
    
    return RadioListTile<LocationAccuracy>(
      title: Text(title),
      subtitle: Text(_getAccuracyDescription(accuracy)),
      value: accuracy,
      groupValue: _selectedAccuracy,
      onChanged: _updateAccuracy,
      activeColor: theme.colorScheme.primary,
      secondary: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onBackground.withOpacity(0.5),
      ),
    );
  }
} 