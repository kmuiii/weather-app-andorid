import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/location_model.dart';

class StorageService {
  static const String _boxName = 'favorites';
  static const String _favKey = 'favorite_locations';
  static const String _lastLocationKey = 'last_location';

  late Box _box;  // hive box buat nyimpen data

  // inisialisasi hive
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // save daftar lokasi fav ke hive
  // future = async
  Future<void> saveFavorites(List<LocationModel> locations) async {
    final jsonList = locations.map((l) => jsonEncode(l.toJson())).toList();
    await _box.put(_favKey, jsonList);
  }

  /// create daftar lokasi fav ke hive
  List<LocationModel> loadFavorites() {
    final raw = _box.get(_favKey);
    if (raw == null) return [];
    final jsonList = (raw as List).cast<String>();
    return jsonList // convert dari json ke model
        .map((s) => LocationModel.fromJson(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  // save lokasi terakhir yang dipilih
  Future<void> saveLastLocation(LocationModel location) async {
    await _box.put(_lastLocationKey, jsonEncode(location.toJson()));
  }

  // load lokasi terakhir yang dipilih
  LocationModel? loadLastLocation() {
    final raw = _box.get(_lastLocationKey);
    if (raw == null) return null;
    return LocationModel.fromJson(
        jsonDecode(raw as String) as Map<String, dynamic>);
  }
}
