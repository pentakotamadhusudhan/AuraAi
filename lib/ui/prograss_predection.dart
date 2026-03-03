import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ProgressPredictionChart extends StatelessWidget {
  final List<double> weeklyData;
  final double prediction;
  final double goal; // Added a goal line for better context

  const ProgressPredictionChart({
    super.key,
    required this.weeklyData,
    required this.prediction,
    this.goal = 2500, // Default water goal
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate dynamic Y-axis bounds
    final allValues = [...weeklyData, prediction, goal];
    final maxY = (allValues.reduce(max) * 1.2)
        .roundToDouble(); // Add 20% padding
    final minY = (allValues.reduce(min) * 0.8).roundToDouble();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progress Prediction Chart",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 1.2,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: _buildTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Line 1: The Goal Line (Static reference)
                  _goalLine(weeklyData.length.toDouble(), goal),
                  // Line 2: Actual Data (Solid)
                  _lineData(weeklyData, Colors.indigo),
                  // Line 3: Prediction (Dashed)
                  if (weeklyData.isNotEmpty)
                    _predictionLine(
                      weeklyData.length - 1,
                      weeklyData.last,
                      prediction,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineData(List<double> data, Color color) {
    return LineChartBarData(
      spots: data
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
    );
  }

  LineChartBarData _predictionLine(
    int lastIdx,
    double lastVal,
    double predVal,
  ) {
    return LineChartBarData(
      spots: [
        FlSpot(lastIdx.toDouble(), lastVal),
        FlSpot(lastIdx.toDouble() + 1, predVal),
      ],
      dashArray: [5, 5],
      color: Colors.orange,
      barWidth: 4,
      dotData: const FlDotData(show: true),
    );
  }

  LineChartBarData _goalLine(double maxX, double goalValue) {
    return LineChartBarData(
      spots: [FlSpot(0, goalValue), FlSpot(maxX, goalValue)],
      dashArray: [2, 10],
      color: Colors.red.withOpacity(0.3),
      barWidth: 2,
      dotData: const FlDotData(show: false),
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Text(
            '${(value / 1000).toStringAsFixed(1)}k',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: _bottomTitleWidgets,
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    // Dynamically calculate day names based on today's index
    final List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    int index = value.toInt();

    // Check if it's the prediction point
    bool isPrediction = index == weeklyData.length;
    String label = isPrediction ? "Pred" : weekDays[index % 7];

    return SideTitleWidget(
      fitInside: SideTitleFitInsideData(
        enabled: true,
        axisPosition: 0.0,
        parentAxisSize: 0.0,
        distanceFromEdge: 10,
      ),
      meta: TitleMeta(
        min: 10,
        max: 300,
        parentAxisSize: 20.0,
        axisPosition: 10.0,
        appliedInterval: 10,
        sideTitles: SideTitles(showTitles: true),
        formattedValue: "",
        axisSide: AxisSide.top,
        rotationQuarterTurns: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isPrediction ? FontWeight.bold : FontWeight.normal,
          color: isPrediction ? Colors.orange : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }
}
