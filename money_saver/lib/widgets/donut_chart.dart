import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DonutChart extends StatefulWidget {
  @override
  _DonutChartState createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Colors.white,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: [
            PieChartSectionData(
                value: 10,
                color: Colors.red,
                title: "10%",
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffffffff),
                ),
                radius: 70),
            PieChartSectionData(
                value: 30,
                color: Colors.green,
                title: "30%",
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffffffff),
                ),
                radius: 70),
            PieChartSectionData(
                value: 40,
                color: Colors.yellow,
                title: "40%",
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffffffff),
                ),
                radius: 70),
            PieChartSectionData(
                value: 20,
                color: Colors.blue,
                title: "20%",
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffffffff),
                ),
                radius: 70),
          ],
        ),
      ),
    );
  }
}
