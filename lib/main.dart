import 'package:current_weather_location/common/routes.dart';
import 'package:current_weather_location/providers/measurement_units_provider.dart';
import 'package:current_weather_location/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MeasurementUnitsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// The starting point of the app.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationService locationService = LocationService();
    return FutureBuilder(
      future: locationService.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Material(
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateInitialRoutes: (initialRoute) {
            return Routes.generateInitialRoute(
              initialRoute,
              locationService.permissionStatus,
            );
          },
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}
