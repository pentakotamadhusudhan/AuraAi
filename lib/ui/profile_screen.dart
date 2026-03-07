import 'package:flutter/material.dart';
import 'package:auraai/models/user_models.dart';
import 'package:auraai/service/notification_service.dart';
import 'package:auraai/service/user_profile_service.dart';
import '../service/health_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // Controllers for text input
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    // Pre-fill controllers if data already exists in the model
    if (UserProfile.weight != null)
      _weightController.text = UserProfile.weight.toString();
    if (UserProfile.height != null)
      _heightController.text = UserProfile.height.toString();
  }

  // Purely triggers a UI refresh to update the BMI/Goal cards

  // Helper to turn your UI strings into DateTime for the model
  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  Future<void> _initializeData() async {
    // 1. Ensure the latest data is loaded from SharedPreferences
    await UserProfile.loadFromDisk();

    // 2. Update the controllers and UI state
    setState(() {
      // Fill text fields if data exists
      if (UserProfile.weight != null && UserProfile.weight != 0) {
        _weightController.text = UserProfile.weight.toString();
      }
      if (UserProfile.height != null && UserProfile.height != 0) {
        _heightController.text = UserProfile.height.toString();
      }
      if (UserProfile.age != null && UserProfile.age != 0) {
        _ageController.text = UserProfile.age.toString();
      }

      UserProfileService().updateAnalysis(
        w: _weightController.text,
        h: _heightController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Set Your Aura",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Uses UserProfile.bmi and UserProfile.waterGoal directly
            _buildAnalysisCard(),
            const SizedBox(height: 30),

            _buildTextField(
              _weightController,
              "Weight (kg)",
              Icons.monitor_weight,
            ),
            const SizedBox(height: 15),
            _buildTextField(_heightController, "Height (cm)", Icons.height),
            const SizedBox(height: 15),
            // Place this above or below weight/height
            _buildTextField(_ageController, "Age", Icons.calendar_today),
            const SizedBox(height: 15),
            _buildGenderDropdown(),
            const SizedBox(height: 15),

            _buildTimeField(
              "Wake up Time",
              UserProfile.wakeUpTime?.toLocal().toString().substring(11, 16) ??
                  "07:00",
              (val) {
                setState(() => UserProfile.wakeUpTime = _parseTime(val));
              },
            ),
            const SizedBox(height: 15),
            _buildTimeField(
              "Sleep Time",
              UserProfile.sleepTime?.toLocal().toString().substring(11, 16) ??
                  "22:00",
              (val) {
                setState(() => UserProfile.sleepTime = _parseTime(val));
              },
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                UserProfile.weight = double.tryParse(_weightController.text);
                UserProfile.height = double.tryParse(_heightController.text);

                if (UserProfile.weight != null && UserProfile.height != null) {
                  await UserProfile.saveToDisk();
                  // if (mounted) Navigator.pop(context);
                }
                UserProfileService().reminderSetService();

                // Example values from your UserProfile model
                await NotificationService.scheduleHydrationRoutine(
                  totalGoalMl: UserProfile.waterGoal, // e.g., 3000.0
                  cupSizeMl: 250.0, // Standard glass size
                  wakeTime: UserProfile.wakeUpTime!,
                  sleepTime: UserProfile.sleepTime!,
                );
              },
              child: const Text(
                "ACTIVATE AURA",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    // Calculating BMI on the fly for the preview
    double weight = double.tryParse(_weightController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0;
    double liveBMI = (weight > 0 && height > 0)
        ? weight / ((height / 100) * (height / 100))
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.purpleAccent],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statColumn("BMI", liveBMI.toStringAsFixed(1)),
          _statColumn("Goal (ml)", UserProfile.waterGoal.toInt().toString()),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => UserProfileService().updateAnalysis(
        w: _weightController.text,
        h: _heightController.text,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: UserProfile.gender ?? 'Male',
      items: [
        'Male',
        'Female',
        'Other',
      ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (val) {
        setState(() => UserProfile.gender = val);
        UserProfileService().updateAnalysis(
          w: _weightController.text,
          h: _heightController.text,
        );
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        labelText: "Gender",
        prefixIcon: const Icon(Icons.person, color: Colors.indigo),
      ),
    );
  }

  Widget _buildTimeField(
    String label,
    String currentTime,
    Function(String) onSave,
  ) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(currentTime.split(':')[0]),
            minute: int.parse(currentTime.split(':')[1]),
          ),
        );
        if (picked != null) {
          onSave(
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}",
          );
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.alarm, color: Colors.indigo),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
          controller: TextEditingController(text: currentTime),
        ),
      ),
    );
  }
}
