import 'package:flutter/material.dart';

import '../service/database_helper.dart';
// Ensure correct path

class GymTrackerScreen extends StatefulWidget {
  const GymTrackerScreen({super.key});

  @override
  State<GymTrackerScreen> createState() => _GymTrackerScreenState();
}

class _GymTrackerScreenState extends State<GymTrackerScreen> {
  final _exerciseController = TextEditingController();
  final _weightController = TextEditingController();
  List<Map<String, dynamic>> _todayWorkouts = [];

  @override
  void initState() {
    super.initState();
    _refreshWorkouts();
  }

  // Load data from SQLite
  void _refreshWorkouts() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('workouts', orderBy: "id DESC");
    setState(() {
      _todayWorkouts = data;
    });
  }

  // Save data to SQLite
  void _addWorkout() async {
    if (_exerciseController.text.isEmpty || _weightController.text.isEmpty) return;

    final db = await DatabaseHelper.instance.database;
    await db.insert('workouts', {
      'exercise': _exerciseController.text,
      'weight': double.parse(_weightController.text),
      'date': DateTime.now().toString(),
    });

    _exerciseController.clear();
    _weightController.clear();
    _refreshWorkouts(); // Refresh the list

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout Logged!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log Workout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Section
            Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _exerciseController,
                    decoration: const InputDecoration(labelText: "Exercise (e.g. Bench Press)"),
                  ),
                  TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: "Weight (kg)"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addWorkout,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Save Set"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Recent History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // History List
            Expanded(
              child: ListView.builder(
                itemCount: _todayWorkouts.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.blue),
                  title: Text(_todayWorkouts[index]['exercise']),
                  subtitle: Text("Weight: ${_todayWorkouts[index]['weight']} kg"),
                  trailing: Text(_todayWorkouts[index]['date'].toString().substring(0, 10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}