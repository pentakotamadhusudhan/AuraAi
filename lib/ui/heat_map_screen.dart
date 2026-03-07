import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../service/heat_map_service.dart';

class DynamicAuraMap extends StatelessWidget {
  const DynamicAuraMap({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, int>>(
      future: AuraHistory.getHeatMapData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Aura Consistency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                HeatMap(
                  datasets: snapshot.data,
                  colorMode: ColorMode.color,
                  defaultColor: Colors.grey[100],
                  textColor: Colors.blueGrey,
                  showColorTip: true,
                  showText: false, // Cleaner for small mobile screens
                  scrollable: true,
                  size: 30, // Size of each square
                  colorsets: {
                    1: Colors.blue.shade100,
                    3: Colors.blue.shade200,
                    5: Colors.blue.shade400,
                    8: Colors.blue.shade600,
                    10: Colors.blue.shade900, // Goal Crushed!
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}