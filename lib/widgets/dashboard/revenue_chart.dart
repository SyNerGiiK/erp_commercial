import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:decimal/decimal.dart';
import '../../utils/format_utils.dart';

class RevenueChart extends StatelessWidget {
  final List<double> monthlyRevenue; // 12 elements
  final int year;
  final bool compact;

  const RevenueChart({
    super.key,
    required this.monthlyRevenue,
    required this.year,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Find max value for Y-axis scaling
    double maxVal = 0;
    for (var d in monthlyRevenue) {
      if (d > maxVal) maxVal = d;
    }
    // Add 20% buffer
    maxVal = maxVal * 1.2;
    if (maxVal == 0) maxVal = 1000;

    final chart = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Chiffre d'Affaires $year",
              style: TextStyle(
                color: const Color(0xff0f4a3c),
                fontSize: compact ? 14 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: compact ? 12 : 24),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: maxVal,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          FormatUtils.currency(
                              Decimal.parse(rod.toY.toString())),
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const months = [
                            'J',
                            'F',
                            'M',
                            'A',
                            'M',
                            'J',
                            'J',
                            'A',
                            'S',
                            'O',
                            'N',
                            'D'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(
                                  color: Color(0xff7589a2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return Container();
                          // Show K units for space
                          if (value >= 1000) {
                            return Text(
                                "${(value / 1000).toDouble().toStringAsFixed(0)}k",
                                style: const TextStyle(fontSize: 10));
                          }
                          return Text(value.toDouble().toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(12, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyRevenue.length > index
                              ? monthlyRevenue[index]
                              : 0,
                          color: const Color(0xFF1E5572),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                  gridData:
                      const FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (compact) {
      return SizedBox(height: 220, child: chart);
    }
    return AspectRatio(aspectRatio: 1.7, child: chart);
  }
}
