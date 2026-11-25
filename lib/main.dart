import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'services/weather_service.dart';
import 'services/storage_service.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'viewmodels/search_viewmodel.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // inisialisasi lokal untuk format tanggal
  await initializeDateFormatting('id_ID', null);

  // inisialisasi service storage hive
  final storageService = StorageService();
  await storageService.init();

  // inisialisasi service networking
  final weatherService = WeatherService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(
            weatherService: weatherService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(
            weatherService: weatherService,
            storageService: storageService,
          ),
        ),
      ],
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
