import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../core/theme.dart';
import '../core/weather_code_helper.dart';
import 'widgets/metric_card.dart';
import 'widgets/daily_forecast_item.dart';
import 'widgets/error_state_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // call init() buat cek lokasi terakhir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Consumer<WeatherViewModel>(
        builder: (context, vm, _) {
          return _buildBody(context, vm);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    switch (vm.state) {
      case WeatherState.loading:
        return _buildLoading();
      case WeatherState.error:
        return _buildError(context, vm);
      case WeatherState.success:
        return _buildSuccess(context, vm);
      case WeatherState.empty:
      case WeatherState.initial:
        return _buildEmpty(context);
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data cuaca...',
            style: TextStyle(color: AppColors.inkMute, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WeatherViewModel vm) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context, vm),
          Expanded(
            child: ErrorStateWidget(
              message: vm.errorMessage ??
                  'Gagal memuat data cuaca. Periksa koneksi internet Anda.',
              onRetry: vm.retry,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cuaca',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                _searchButton(context),
              ],
            ),
          ),
          Expanded(
            child: EmptyStateWidget(
              icon: Icons.location_city_rounded,
              title: 'Belum Ada Lokasi',
              subtitle:
                  'Cari kota untuk melihat prakiraan cuaca terkini.',
              action: ElevatedButton.icon(
                onPressed: () => _openSearch(context),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: const Text('Cari Kota'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, WeatherViewModel vm) {
    final weather = vm.weather!;
    final location = vm.selectedLocation!;
    final current = weather.current;
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // AppBar
          SliverToBoxAdapter(
            child: _buildAppBar(context, vm),
          ),

          // Hero Card — Suhu Utama
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _buildHeroCard(context, vm, location.name, current),
            ),
          ),

          // Kartu Metrik Tambahan
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Atmosfer',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: screenWidth > 400 ? 2 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      MetricCard(
                        icon: Icons.water_drop_rounded,
                        label: 'Kelembapan',
                        value: '${current.relativeHumidity2m}%',
                        iconColor: const Color(0xFF054CFF),
                      ),
                      MetricCard(
                        icon: Icons.air_rounded,
                        label: 'Kec. Angin',
                        value: '${current.windSpeed10m.toStringAsFixed(1)} km/j',
                        iconColor: AppColors.primarySoft,
                      ),
                      MetricCard(
                        icon: Icons.umbrella_rounded,
                        label: 'Curah Hujan',
                        value: '${current.precipitation} mm',
                        iconColor: const Color(0xFF054CFF),
                      ),
                      MetricCard(
                        icon: Icons.thermostat_rounded,
                        label: 'Suhu Terasa',
                        value:
                            '${current.apparentTemperature.toStringAsFixed(1)}°C',
                        iconColor: AppColors.accentTomato,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Prakiraan Harian
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Prakiraan 7 Hari',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weather.daily.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AppColors.hairlineCool,
                  ),
                  itemBuilder: (context, index) => DailyForecastItem(
                    forecast: weather.daily[index],
                    isFirst: index == 0,
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WeatherViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              vm.selectedLocation?.name ?? 'Cuaca',
              style: Theme.of(context).textTheme.headlineLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _searchButton(context),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    WeatherViewModel vm,
    String cityName,
    dynamic current,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.canvasNight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // lokasi & tanggal
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  vm.selectedLocation?.displayName ?? cityName,
                  style: const TextStyle(
                    color: AppColors.inkMute2,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // icon & suhu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                WeatherCodeHelper.getIcon(current.weatherCode),
                color: WeatherCodeHelper.getIconColor(current.weatherCode),
                size: 56,
              ),
              const SizedBox(width: 16),
              Text(
                '${current.temperature2m.round()}°',
                style: const TextStyle(
                  color: AppColors.onDark,
                  fontSize: 64,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -1.92,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // deskripsi kondisi
          Text(
            WeatherCodeHelper.getDescription(current.weatherCode),
            style: const TextStyle(
              color: AppColors.onDark,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Terasa ${current.apparentTemperature.toStringAsFixed(1)}°C',
            style: const TextStyle(
              color: AppColors.inkMute2,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // pill tag 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Text(
              'Live · Open-Meteo',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchButton(BuildContext context) {
    return IconButton(
      onPressed: () => _openSearch(context),
      icon: const Icon(Icons.search_rounded),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.canvasSoft,
        foregroundColor: AppColors.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),
      tooltip: 'Cari Kota',
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    // refresh data cuaca setelah kembali dari pencarian
  }
}
