import 'package:current_weather_location/common/constants.dart';
import 'package:current_weather_location/providers/measurement_units_provider.dart';
import 'package:current_weather_location/services/location_service.dart';
import 'package:current_weather_location/widgets/settings_popup_menu.dart';
import 'package:current_weather_location/widgets/slider_sunrise_sunset.dart';
import 'package:flutter/material.dart';
import 'package:google_ads_widgets/google_ads_widgets.dart';
import 'package:intl/intl.dart';
import 'package:open_weather_map_client/open_weather_map_client.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationService location = LocationService();
    return FutureBuilder(
      future: location.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return _CurrentWeather(
          latitude: location.locationData.latitude ?? 0.0,
          longitude: location.locationData.longitude ?? 0.0,
        );
      },
    );
  }
}

class _CurrentWeather extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _CurrentWeather({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OpenWeatherMapProvider.byLocation(
        latitude: latitude,
        longitude: longitude,
        apiKey: apiWeatherKey,
        loadForecast: false,
        langCode: Localizations.localeOf(context).countryCode,
      ),
      builder: (context, child) {
        return FutureBuilder(
          future: Future.wait([
            context.read<OpenWeatherMapProvider>().load(),
            context.read<MeasurementUnitsProvider>().load(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                centerTitle: true,
                title: Text(
                  context.watch<OpenWeatherMapProvider>().city.name ?? '',
                  style: const TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: const [
                  SettingsPopupMenu(),
                ],
              ),
              body: _Body(context.watch<OpenWeatherMapProvider>().weather),
            );
          },
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final Weather weather;
  const _Body(this.weather);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            _image(weather.condition),
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<OpenWeatherMapProvider>().update();
                },
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 120.0,
                    ),
                    _CurrentTemperature(weather: weather),
                    Center(
                      child: Text(
                        weather.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 60.0,
                    ),
                    const _WeatherDetailCard(),
                  ],
                ),
              ),
            ),
            BannerAdWidget(
              adUnitId: const Ads().banner,
            )
          ],
        ),
      ),
    );
  }

  String _image(String condition) {
    switch (condition) {
      case 'Tornado':
        return 'assets/images/tornado_background.jpg';
      case 'Squall':
        return 'assets/images/squall_background.jpg';
      case 'Ash':
        return 'assets/images/ash_background.jpg';
      case 'Sand':
        return 'assets/images/sand_background.jpg';
      case 'Dust':
        return 'assets/images/dust_background.jpg';
      case 'Smoke':
        return 'assets/images/smoke_background.jpg';
      case 'Fog':
        return 'assets/images/mist_background.jpg';
      case 'Haze':
        return 'assets/images/mist_background.jpg';
      case 'Mist':
        return 'assets/images/mist_background.jpg';
      case 'Snow':
        return 'assets/images/snow_background.jpg';
      case 'Rain':
        return 'assets/images/rain_background.jpg';
      case 'Drizzle':
        return 'assets/images/drizzle_background.jpg';
      case 'Thunderstorm':
        return 'assets/images/thunderstorm_background.jpg';
      case 'Clouds':
        return 'assets/images/clouds_background.jpg';
      default:
        return 'assets/images/clear_background.jpg';
    }
  }
}

class _CurrentTemperature extends StatelessWidget {
  final Weather weather;

  const _CurrentTemperature({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<MeasurementUnitsProvider>(
        builder: (context, value, child) {
          if (value.temperatureUnits == TemperatureUnits.celsius) {
            return Text(
              '${weather.temperatureInCelsius.toStringAsFixed(2)} ${AppLocalizations.of(context)!.celsiusDegreesSymbol}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            );
          }
          if (value.temperatureUnits == TemperatureUnits.fahrenheit) {
            return Text(
              '${weather.temperatureInFahrenheit.toStringAsFixed(2)} ${AppLocalizations.of(context)!.fahrenheitDegreesSymbol}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            );
          }
          return Text(
            '${weather.temperature.toStringAsFixed(2)} ${AppLocalizations.of(context)!.kelvinDegreesSymbol}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }
}

class _WeatherDetailCard extends StatelessWidget {
  const _WeatherDetailCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380.0),
        child: Card(
          color: Colors.black.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Table(
              children: [
                const TableRow(
                  children: [
                    SizedBox(
                      height: 60.0,
                    ),
                  ],
                ),
                const TableRow(
                  children: [
                    SliderSunriseSunset(),
                  ],
                ),
                TableRow(
                  children: [
                    Builder(
                      builder: (context) {
                        final String sunset = DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            context
                                    .watch<OpenWeatherMapProvider>()
                                    .city
                                    .sunset!
                                    .toUtc()
                                    .millisecondsSinceEpoch +
                                context
                                        .watch<OpenWeatherMapProvider>()
                                        .city
                                        .timezone! *
                                    1000,
                          ).toUtc(),
                        );
                        final String sunrise = DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            context
                                    .watch<OpenWeatherMapProvider>()
                                    .city
                                    .sunrise!
                                    .toUtc()
                                    .millisecondsSinceEpoch +
                                context
                                        .watch<OpenWeatherMapProvider>()
                                        .city
                                        .timezone! *
                                    1000,
                          ).toUtc(),
                        );
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.sunrise}\n$sunrise',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                            Text(
                              '${AppLocalizations.of(context)!.sunset}\n$sunset',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const TableRow(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<MeasurementUnitsProvider>(
                          builder: (context, value, child) {
                            if (value.temperatureUnits ==
                                TemperatureUnits.celsius) {
                              return Text(
                                '${AppLocalizations.of(context)!.realFeeling}\n${context.watch<OpenWeatherMapProvider>().weather.temperatureFeelsLikeInCelsius?.toStringAsFixed(2)} ${AppLocalizations.of(context)!.celsiusDegreesSymbol}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              );
                            }
                            if (value.temperatureUnits ==
                                TemperatureUnits.fahrenheit) {
                              return Text(
                                '${AppLocalizations.of(context)!.realFeeling}\n${context.watch<OpenWeatherMapProvider>().weather.temperatureFeelsLikeInFahrenheit?.toStringAsFixed(2)} ${AppLocalizations.of(context)!.fahrenheitDegreesSymbol}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              );
                            }
                            return Text(
                              '${AppLocalizations.of(context)!.realFeeling}\n${context.watch<OpenWeatherMapProvider>().weather.temperatureFeelsLike} ${AppLocalizations.of(context)!.kelvinDegreesSymbol}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            );
                          },
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.humidity}\n${context.watch<OpenWeatherMapProvider>().weather.humidity} %',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const TableRow(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
                TableRow(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Consumer<MeasurementUnitsProvider>(
                        builder: (context, value, child) {
                          if (value.windSpeedUnits ==
                              WindSpeedUnits.kilometersHour) {
                            return Text(
                              '${AppLocalizations.of(context)!.windSpeed}\n${context.watch<OpenWeatherMapProvider>().weather.windSpeedInKilometersPerHour.toStringAsFixed(2)} km/h',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            );
                          }
                          if (value.windSpeedUnits ==
                              WindSpeedUnits.milesHour) {
                            return Text(
                              '${AppLocalizations.of(context)!.windSpeed}\n${context.watch<OpenWeatherMapProvider>().weather.windSpeedInMilesPerHour.toStringAsFixed(2)} mi/h',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            );
                          }
                          if (value.windSpeedUnits == WindSpeedUnits.knots) {
                            return Text(
                              '${AppLocalizations.of(context)!.windSpeed}\n${context.watch<OpenWeatherMapProvider>().weather.windSpeedInKnots.toStringAsFixed(2)} kn',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            );
                          }
                          return Text(
                            '${AppLocalizations.of(context)!.windSpeed}\n${context.watch<OpenWeatherMapProvider>().weather.windSpeed} m/s',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          );
                        },
                      ),
                      Consumer<MeasurementUnitsProvider>(
                        builder: (context, value, child) {
                          if (value.pressureUnits == PressureUnits.atmosphere) {
                            return Text(
                              '${AppLocalizations.of(context)!.pressure}\n${context.watch<OpenWeatherMapProvider>().weather.pressureInAtmosphere} atm',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            );
                          }
                          if (value.pressureUnits ==
                              PressureUnits.millimetersMercury) {
                            return Text(
                              '${AppLocalizations.of(context)!.pressure}\n${context.watch<OpenWeatherMapProvider>().weather.pressureInMillimetersOfMercury} mmHg',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                            );
                          }
                          return Text(
                            '${AppLocalizations.of(context)!.pressure}\n${context.watch<OpenWeatherMapProvider>().weather.pressure} hPa',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
