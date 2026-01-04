import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const ChartContainer({Key? key, required this.title, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class VisitorCountChart extends StatelessWidget {
  const VisitorCountChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Mock data: 7 days
    final spots = [
      const FlSpot(0, 12),
      const FlSpot(1, 15),
      const FlSpot(2, 8),
      const FlSpot(3, 11),
      const FlSpot(4, 20),
      const FlSpot(5, 25),
      const FlSpot(6, 18),
    ];

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                   return Text(value.toInt().toString(), style: theme.textTheme.bodySmall?.copyWith(fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt()], style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: primaryColor.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }
}

class PeakHoursChart extends StatelessWidget {
  const PeakHoursChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

     return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                   final style = theme.textTheme.bodySmall?.copyWith(fontSize: 10);
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = '8AM';
                      break;
                    case 1:
                      text = '12PM';
                      break;
                    case 2:
                      text = '4PM';
                      break;
                    case 3:
                      text = '8PM';
                      break;
                    default:
                      return Container();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(text, style: style),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: 8, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: 15, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: 12, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [BarChartRodData(toY: 10, color: primaryColor, width: 16, borderRadius: BorderRadius.circular(4))],
            ),
          ],
        ),
      ),
    );
  }
}

class GuardStatusChart extends StatelessWidget {
  const GuardStatusChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: 70,
                  title: '70%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: theme.disabledColor,
                  value: 30,
                  title: '30%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Colors.green, text: 'Active'),
            const SizedBox(width: 16),
            _LegendItem(color: theme.disabledColor, text: 'Inactive'),
          ],
        )
      ],
    );
  }
}

class ApprovalRateChart extends StatelessWidget {
  const ApprovalRateChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
      return Column(
        children: [
          SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: 60,
                  title: '60%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: 10,
                  title: '10%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                 PieChartSectionData(
                  color: Colors.orange,
                  value: 30,
                  title: '30%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
                ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Colors.blue, text: 'Approved'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.orange, text: 'Pending'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.red, text: 'Rejected'),
            ],
          )
        ],
      );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      );
  }
}
