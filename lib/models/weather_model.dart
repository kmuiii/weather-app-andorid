class CurrentWeather {
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;
  final String time;

  CurrentWeather({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.time,
  });

  // convert dari json ke model
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
      time: json['time'] as String,
    );
  }
}

// data cuaca harian
class DailyForecast {
  final String date;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });

  factory DailyForecast.fromJson({
    required String date,
    required Map<String, dynamic> daily,
    required int index,
  }) {
    return DailyForecast( // convert dari json ke model
      date: date,
      temperatureMax: (daily['temperature_2m_max'][index] as num).toDouble(),
      temperatureMin: (daily['temperature_2m_min'][index] as num).toDouble(),
      precipitationProbabilityMax:
          (daily['precipitation_probability_max'][index] as num).toInt(),
      weatherCode: (daily['weather_code'][index] as num).toInt(),
    );
  }
}

// data cuaca secara keseluruhan
class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;
    final dailyTimes = (dailyJson['time'] as List).cast<String>();

    final dailyForecasts = List<DailyForecast>.generate(
      dailyTimes.length,
      (i) => DailyForecast.fromJson(
        date: dailyTimes[i],
        daily: dailyJson,
        index: i,
      ),
    );

    return WeatherModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      current: CurrentWeather.fromJson(currentJson),
      daily: dailyForecasts,
    );
  }
}
