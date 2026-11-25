import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

enum SearchState { initial, loading, success, error, empty }  // statte untuk search

class SearchViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  SearchViewModel({
    required WeatherService weatherService,
    required StorageService storageService,
  })  : _weatherService = weatherService, // inisialisasi service
        _storageService = storageService;

  // state untuk search, hasil search, daftar favorit, & pesan error
  SearchState _state = SearchState.initial;
  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  String? _errorMessage;

  // getter
  SearchState get state => _state;
  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favorites => _favorites;
  String? get errorMessage => _errorMessage;

  // inisialisasi daftar fav dari storage service
  void init() {
    _favorites = _storageService.loadFavorites();
    notifyListeners();
  }

  // search lokasi via weather service
  Future<void> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _state = SearchState.initial;
      notifyListeners();
      return;
    }

    _state = SearchState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _weatherService.searchLocations(query);
      _searchResults = results;
      _state = results.isEmpty ? SearchState.empty : SearchState.success;
    } catch (e) {
      _errorMessage = 'Gagal mencari lokasi. Periksa koneksi internet Anda.';
      _state = SearchState.error;
    }

    notifyListeners();
  }

  // cek lokasi fav?
  bool isFavorite(LocationModel location) {
    return _favorites.any((f) => f.id == location.id);
  }

  // togle lokasi fav
  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      _favorites.removeWhere((f) => f.id == location.id);
    } else {
      _favorites.add(location);
    }
    await _storageService.saveFavorites(_favorites);
    notifyListeners();
  }

  // remove lokasi fav
  Future<void> removeFavorite(LocationModel location) async {
    _favorites.removeWhere((f) => f.id == location.id);
    await _storageService.saveFavorites(_favorites);
    notifyListeners();
  }

  // clear search results
  void clearSearch() {
    _searchResults = [];
    _state = SearchState.initial;
    notifyListeners();
  }
}
