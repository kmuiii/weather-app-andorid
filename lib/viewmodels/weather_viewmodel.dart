import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

enum WeatherState { initial, loading, success, error, empty }

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  WeatherViewModel({
    required WeatherService weatherService,
    required StorageService storageService,
  })  : _weatherService = weatherService,
        _storageService = storageService;

  // state untuk cuaca, data cuaca, lokasi yang dipilih, & pesan error
  WeatherState _state = WeatherState.initial;
  WeatherModel? _weather;
  LocationModel? _selectedLocation;
  String? _errorMessage;

  // getter
  WeatherState get state => _state;
  WeatherModel? get weather => _weather;
  LocationModel? get selectedLocation => _selectedLocation;
  String? get errorMessage => _errorMessage;

  // inisialisasi lokasi terakhir
  Future<void> init() async {
    final lastLocation = _storageService.loadLastLocation();
    if (lastLocation != null) {
      await selectLocation(lastLocation);
    } else {
      _state = WeatherState.empty;
      notifyListeners();
    }
  }

  // select lokasi
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await fetchWeather();
    await _storageService.saveLastLocation(location);
  }

  // fetch data cuaca
  Future<void> fetchWeather() async {
    if (_selectedLocation == null) return;

    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _weatherService.fetchWeather(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );
      _weather = result;
      _state = WeatherState.success;
    } catch (e) {
      _errorMessage = 'Gagal memuat data cuaca. Periksa koneksi internet Anda.';
      _state = WeatherState.error;
    }

    notifyListeners();
  }

  Future<void> retry() async {
    await fetchWeather();
  }
}
