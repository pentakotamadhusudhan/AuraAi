import 'package:flutter/material.dart';


class AuraInsightCard extends StatelessWidget {
  final String insight;

  const AuraInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              insight,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}