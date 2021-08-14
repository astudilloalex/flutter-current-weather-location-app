import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

/// It contains what is necessary to request and access the user's location
/// and display the weather.
class LocationService {
  /// Define a Location class.
  final Location _location = Location();

  /// Detailed location data.
  late LocationData _locationData;

  /// Permission status of the location.
  late PermissionStatus _permissionStatus;

  /// Is location service enabled.
  late bool _serviceEnabled;

  /// If the user did not give permission to the application, we can
  /// call this function.
  Future<void> requestPermission() async {
    await Permission.location.request().then((value) async {
      if (value.isPermanentlyDenied) {
        await openAppSettings().then((value) async {
          if (value) {
            await init();
          }
        });
      }
    });
  }

  /// Load all data this is required call on init.
  Future<void> init() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }
    _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await _location.getLocation();
  }

  /// Returns the detailed location.
  LocationData get locationData => _locationData;

  /// Returns the [PermissionStatus] of location.
  PermissionStatus get permissionStatus => _permissionStatus;

  /// Returns true if location service is enabled.
  bool get serviceEnabled => _serviceEnabled;
}
