import 'dart:io';

const String apiWeatherKey = 'b29a20f7678dc6322dead641bd6e5ff8';

class Ads {
  const Ads();

  String get banner {
    if (Platform.isAndroid) return 'ca-app-pub-2503192367716639/6126494577';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    throw 'Unsupported platform';
  }
}

/// Keys to use with the shared_preferences package.
class PrefsKeys {
  String get temperatureUnit => 'temperatureUnit';
  String get pressureUnit => 'pressureUnit';
  String get windSpeedUnit => 'windSpeedUnit';
}

/// Units of measurement of atmosferic pressure.
enum PressureUnits {
  atmosphere,
  hectoPascal,
  millimetersMercury,
}

/// Units of measurement of temperature.
enum TemperatureUnits {
  celsius,
  fahrenheit,
  kelvin,
}

/// Units of measurement of wind speed.
enum WindSpeedUnits {
  kilometersHour,
  knots,
  metersSecond,
  milesHour,
}
