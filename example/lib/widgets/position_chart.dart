import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/keyword_tracking.dart';

class PositionChart extends StatelessWidget {
  final List<KeywordTracking> trackings;

  const PositionChart({
    Key? key,
    required this.trackings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trackings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Aucune donnée de tracking disponible',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Trier par date
    final sortedTrackings = List<KeywordTracking>.from(trackings)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Préparer les données pour le graphique
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedTrackings.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedTrackings[i].position.toDouble()));
    }

    // Trouver les valeurs min/max pour l'axe Y
    final positions = sortedTrackings.map((t) => t.position).toList();
    final maxPosition = positions.reduce((a, b) => a > b ? a : b);
    final minPosition = positions.reduce((a, b) => a < b ? a : b);

    // Ajouter une marge
    final yMax = (maxPosition + 10).toDouble();
    final yMin = (minPosition - 5 > 0 ? minPosition - 5 : 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution de la position',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Plus la courbe est basse, meilleur est le classement',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedTrackings.length) {
                          return const Text('');
                        }
                        final date = sortedTrackings[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                minX: 0,
                maxX: (sortedTrackings.length - 1).toDouble(),
                minY: yMin,
                maxY: yMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.blue[300]!,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.3),
                          Colors.blue.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= sortedTrackings.length) {
                          return null;
                        }
                        final tracking = sortedTrackings[index];
                        return LineTooltipItem(
                          'Position: ${tracking.position}\n'
                          '${DateFormat('dd/MM/yyyy').format(tracking.date)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStats(sortedTrackings),
        ],
      ),
    );
  }

  Widget _buildStats(List<KeywordTracking> trackings) {
    final firstPosition = trackings.first.position;
    final lastPosition = trackings.last.position;
    final change = firstPosition - lastPosition;

    final bestPosition = trackings.map((t) => t.position).reduce((a, b) => a < b ? a : b);
    final worstPosition = trackings.map((t) => t.position).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Évolution',
              change > 0 ? '+$change' : '$change',
              change > 0 ? Colors.green : (change < 0 ? Colors.red : Colors.grey),
            ),
            _buildStatItem(
              'Meilleure',
              '#$bestPosition',
              Colors.blue,
            ),
            _buildStatItem(
              'Pire',
              '#$worstPosition',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
