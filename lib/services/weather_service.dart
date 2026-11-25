import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/location_model.dart';

class WeatherService {
  // base url buat forecast api
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl ='https://geocoding-api.open-meteo.com/v1/search';

  // fetch data cuaca dari open-meteo api
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': [
          'temperature_2m',
          'relative_humidity_2m',
          'apparent_temperature',
          'precipitation',
          'weather_code',
          'wind_speed_10m',
        ].join(','),
        'daily': [
          'temperature_2m_max',
          'temperature_2m_min',
          'precipitation_probability_max',
          'weather_code',
        ].join(','),
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));  //  timeout 15s untuk fetch data cuaca

    // cek status code dari response
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(json);
    } else {
      throw Exception(
          'Gagal mengambil data cuaca. Status: ${response.statusCode}');
    }
  }

  // search kota via geocoding api
  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];  // jika query kosong, return list kosong

    final uri = Uri.parse(_geocodingBaseUrl).replace(
      queryParameters: {
        'name': query.trim(),
        'count': '10',
        'language': 'id',
        'format': 'json',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 10));  // timeout 10s untuk search lokasi

    // sama, cek status dari response
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'];
      if (results == null) return [];
      return (results as List)
          .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          'Gagal mencari lokasi. Status: ${response.statusCode}');
    }
  }
}
