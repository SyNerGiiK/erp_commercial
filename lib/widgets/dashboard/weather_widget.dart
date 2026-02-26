import 'package:flutter/material.dart';
import '../../services/weather_service.dart';
import '../../config/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WeatherWidget extends StatefulWidget {
  final String city;
  const WeatherWidget({super.key, this.city = 'Paris'});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final data = await WeatherService.getCurrentWeather(city: widget.city);
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        width: 150,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_weatherData == null) {
      // Affichage de secours chic si pas de clé API ou erreur
      return _buildGlassCard(
        icon: Icons.cloud_outlined,
        temp: "--°C",
        desc: "Météo Indisp.",
      );
    }

    final double temp = _weatherData!['main']['temp'] ?? 0.0;
    final String desc = _weatherData!['weather']?[0]?['description'] ?? '';
    final String iconCode = _weatherData!['weather']?[0]?['icon'] ?? '01d';

    return _buildGlassCard(
      iconUrl: 'https://openweathermap.org/img/wn/$iconCode.png',
      temp: '${temp.round()}°C',
      desc: desc,
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildGlassCard(
      {IconData? icon,
      String? iconUrl,
      required String temp,
      required String desc}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGlassBright,
        borderRadius: AppTheme.borderRadiusMedium,
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconUrl != null)
            Image.network(iconUrl, width: 40, height: 40)
          else if (icon != null)
            Icon(icon, color: AppTheme.textSecondary, size: 30),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(temp,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary)),
              Text(desc.length > 15 ? '${desc.substring(0, 15)}...' : desc,
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
