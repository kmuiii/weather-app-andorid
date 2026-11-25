import 'package:flutter/material.dart';

class WeatherCodeHelper {

  // get weather description based on the weather code
  static String getDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Sebagian Berawan';
      case 3:
        return 'Berawan';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Beku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
        return 'Salju Ringan';
      case 73:
        return 'Salju Sedang';
      case 75:
        return 'Salju Lebat';
      case 77:
        return 'Butiran Salju';
      case 80:
        return 'Hujan Shower Ringan';
      case 81:
        return 'Hujan Shower Sedang';
      case 82:
        return 'Hujan Shower Lebat';
      case 85:
      case 86:
        return 'Hujan Salju';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir + Hujan Es';
      default:
        return 'Tidak Diketahui';
    }
  }

  // get weather icon based on the weather code
  static IconData getIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code == 1 || code == 2) return Icons.cloud_queue_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain_rounded;
    if (code >= 61 && code <= 67) return Icons.water_drop_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.umbrella_rounded;
    if (code >= 85 && code <= 86) return Icons.cloudy_snowing;
    if (code == 95) return Icons.thunderstorm_rounded;
    if (code == 96 || code == 99) return Icons.severe_cold_rounded;
    return Icons.cloud_queue_rounded;
  }

  // get weather icon color based on the weather code
  static Color getIconColor(int code) {
    if (code == 0) return const Color(0xFFFFDB13); // cerah
    if (code <= 2) return const Color(0xFFFFDB13); // cerah berawan
    if (code == 3) return const Color(0xFF9A9A9A); // berawan
    if (code == 45 || code == 48) return const Color(0xFFB2B2B2); // berkabut
    if (code >= 51 && code <= 57) return const Color(0xFF4ADE80); // gerimis
    if (code >= 61 && code <= 67) return const Color(0xFF054CFF); // hujan
    if (code >= 71 && code <= 77) return const Color(0xFFB2D8FF); // salju
    if (code >= 80 && code <= 82) return const Color(0xFF054CFF); // hujaan shower
    if (code >= 95) return const Color(0xFF6B01C2); // badai petir
    return const Color(0xFF9A9A9A); // default color
  }
}
