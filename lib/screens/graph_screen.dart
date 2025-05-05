import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  // Mock data for acne analysis results
  final List<Map<String, dynamic>> mockData = [
    {'analysis_date': '2025-02-10', 'total_acne_count': 5},
    {'analysis_date': '2025-02-09', 'total_acne_count': 3},
    {'analysis_date': '2025-02-08', 'total_acne_count': 8},
    {'analysis_date': '2025-02-07', 'total_acne_count': 4},
    {'analysis_date': '2025-02-06', 'total_acne_count': 6},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("กราฟพัฒนาการการรักษาผิว"),
        backgroundColor: Color(0xFFCDF8F7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          var date = mockData[value.toInt()]['analysis_date'];
                          return RotatedBox(
                            quarterTurns: 1, // Rotate titles to make them readable
                            child: Text(
                              date,
                              style: TextStyle(fontSize: 10, color: Colors.black),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: mockData
                          .asMap()
                          .map((index, e) => MapEntry(
                                index.toDouble(),
                                FlSpot(index.toDouble(), e['total_acne_count'].toDouble()),
                              ))
                          .values
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text("กลับ"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
