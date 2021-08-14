import 'package:current_weather_location/common/constants.dart';
import 'package:current_weather_location/common/routes.dart';
import 'package:current_weather_location/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_ads_widgets/google_ads_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:location/location.dart';

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationService locationService = LocationService();
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BannerAdWidget(adUnitId: const Ads().banner),
            FutureBuilder(
              future: locationService.init(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                return const _RequestPermission();
              },
            ),
            BannerAdWidget(adUnitId: const Ads().banner),
          ],
        ),
      ),
    );
  }
}

class _RequestPermission extends StatelessWidget {
  const _RequestPermission();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 150.0,
            child: Text(AppLocalizations.of(context)!.locationInfo),
          ),
          const SizedBox(width: 150.0, child: Divider()),
          const _OpenSettings(),
        ],
      ),
    );
  }
}

class _OpenSettings extends StatefulWidget {
  const _OpenSettings();

  @override
  __OpenSettingsState createState() => __OpenSettingsState();
}

class __OpenSettingsState extends State<_OpenSettings> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: !loading
          ? () async {
              setState(() {
                loading = true;
              });
              final LocationService locationService = LocationService();
              await locationService.init();
              await locationService.requestPermission();
              setState(() {
                loading = false;
              });
              if (locationService.permissionStatus ==
                  PermissionStatus.granted) {
                Navigator.of(context).pushReplacementNamed(Routes.home);
              }
            }
          : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(150.0, 36.0),
      ),
      icon: const Icon(Icons.location_on_outlined),
      label: loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Text(AppLocalizations.of(context)!.allowLocation),
    );
  }
}
