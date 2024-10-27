import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StressLevelDisplay extends StatelessWidget {
  final int stressLevel;
  final String stressState;
  final List<int> stressLevelData; // Dynamic stress level data
  final List<int> timeData; // Dynamic time data

  const StressLevelDisplay({
    super.key,
    required this.stressLevel,
    required this.stressState,
    required this.stressLevelData,
    required this.timeData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350, // Adjust width here
      height: 325,

      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
      ),




      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with the title and icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stress Level: $stressLevel', style: const TextStyle(fontSize: 16)),
              const Row(
                children: [
                  Icon(Icons.show_chart, color: Colors.pink),
                  SizedBox(width: 8),
                  Icon(Icons.share, color: Colors.pink),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Use SizedBox to set a fixed height for the chart
          SizedBox(
            height: 200, // You can adjust this height as needed
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawHorizontalLine: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 10, // Interval for Y-axis
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}'); // Y-axis labels
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1, // Display all minutes in the limited range
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < timeData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('${timeData[index]} min', style: const TextStyle(fontSize: 10)),
                          );
                        } else {
                          return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Colors.black, width: 1),
                    left: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      stressLevelData.length,
                      (i) => FlSpot(i.toDouble(), stressLevelData[i].toDouble()),
                    ), // Create spots for the dynamic stress levels
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.pink,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                minY: 0,
                maxY: 60, // Y-axis range
                minX: 0,
                maxX: 4, // Only show the most recent 5 minutes on the X-axis
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Stress State label
          Center(
            child: Text(
              stressState,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ));
  }
}
