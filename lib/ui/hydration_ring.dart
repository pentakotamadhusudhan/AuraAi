import 'package:flutter/material.dart';
import 'package:auraai/models/user_models.dart';
import 'package:water_bottle/water_bottle.dart';


var waterLevel = 0.0;
var selectedStyle = 0;
final sphereBottleRef = GlobalKey<WaterBottleState>();


class HydrationRing extends StatefulWidget {
  final double progress; // Value between 0.0 and 1.0
  final double currentAmount;
  final Function(double) onWaterUpdated; // Callback to notify parent of changes

  const HydrationRing({
    super.key,
    required this.progress,
    required this.currentAmount,
    required this.onWaterUpdated,
  });

  @override
  State<HydrationRing> createState() => _HydrationRingState();
}

class _HydrationRingState extends State<HydrationRing> {


  // Use a local state variable initialized from the widget/model
  late double localWaterLevel;

  @override
  void initState() {
    super.initState();
    localWaterLevel = widget.progress;
  }

  // Helper to show the slider in a BottomSheet
  void _showWaterAdjuster() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Necessary to update slider inside BottomSheet
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 150,
              child: Column(
                children: [
                  const Text(
                    "Adjust Water Intake",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.opacity, color: Colors.blue),
                      Expanded(
                        child: SphericalBottle(
                        key: sphereBottleRef,
                        waterColor: Colors.red,
                        bottleColor: Colors.redAccent,
                        capColor: Colors.grey.shade700,
                      )
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showWaterAdjuster, // Now correctly triggers the UI
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 180,
            width: 180,
            child: SphericalBottle(
              key: sphereBottleRef,
              // Initial level
              waterColor: Colors.blue.withOpacity(0.6),
              bottleColor: Colors.blueAccent,
              capColor: Colors.grey.shade700,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(widget.progress * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const Icon(Icons.water_drop, color: Colors.blue, size: 24),
                ],
              ),
              Text(
                "${widget.currentAmount.toInt()} / ${UserProfile.waterGoal.toInt()} ml",
                style: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
