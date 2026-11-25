import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/weather_code_helper.dart';
import '../../models/weather_model.dart';

// widget item untuk menampilkan perkiraan cuaca harian
class DailyForecastItem extends StatelessWidget {
  final DailyForecast forecast;
  final bool isFirst;

  const DailyForecastItem({
    super.key,
    required this.forecast,
    this.isFirst = false,
  });

  // format tanggal
  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    if (isFirst) return 'Hari ini';
    return DateFormat('EEE, d MMM', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          // Tanggal
          SizedBox(
            width: 100,
            child: Text(
              _formatDate(forecast.date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isFirst ? AppColors.ink : AppColors.inkSecondary,
                    fontWeight: isFirst ? FontWeight.w500 : FontWeight.w400,
                  ),
            ),
          ),

          // icon cuaca
          Icon(
            WeatherCodeHelper.getIcon(forecast.weatherCode),
            color: WeatherCodeHelper.getIconColor(forecast.weatherCode),
            size: 20,
          ),
          const SizedBox(width: 8),

          // peluang hujan
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.water_drop_outlined,
                  size: 14,
                  color: AppColors.inkMute2,
                ),
                const SizedBox(width: 2),
                Text(
                  '${forecast.precipitationProbabilityMax}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMute,
                      ),
                ),
              ],
            ),
          ),

          // suhu min & max
          Row(
            children: [
              Text(
                '${forecast.temperatureMin.round()}°',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMute,
                    ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ADE80), Color(0xFFFFDB13)],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${forecast.temperatureMax.round()}°',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
