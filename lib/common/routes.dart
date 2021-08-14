import 'package:current_weather_location/routes/home/home_page.dart';
import 'package:current_weather_location/routes/location_permission/location_permission_page.dart';
import 'package:current_weather_location/routes/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

class Routes {
  static const String home = '/';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsPage(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomePage(),
        );
    }
  }

  static List<Route<dynamic>> generateInitialRoute(
    String initialRoute,
    PermissionStatus permissionStatus,
  ) {
    return [
      if (permissionStatus != PermissionStatus.granted)
        MaterialPageRoute(
          builder: (_) => const LocationPermissionPage(),
        ),
      if (permissionStatus == PermissionStatus.granted)
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
    ];
  }
}
