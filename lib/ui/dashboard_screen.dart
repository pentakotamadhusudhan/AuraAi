import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:auraai/service/initative_service.dart';
import 'package:auraai/service/notification_service.dart';
import 'package:auraai/ui/prograss_predection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:auraai/service/water_service.dart';
import 'package:auraai/ui/profile_screen.dart';
import '../models/user_models.dart';
import '../service/database_helper.dart';
import '../service/health_service.dart';
import '../service/weather_service.dart';
import 'gym_tracker_screen.dart';
import 'hydration_ring.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _weatherFuture;
  double score = 0.0;
  double _dailyWater = 0.0;
  double _goal = 0.0;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _loadWeather(); // ← initialize immediately
    _loadDailyWater();
    _loadWeeklyData();
    _loadReadliness();
    InitialService().setValues();
  }

  Future<void> _loadReadliness() async {
    final value = await HealthCalculator().calculateReadiness(4);
    await InitialService().setValues();

    if (mounted) {
      setState(() {
        score = value;
      });
    }
  }

  Future<Map<String, dynamic>> _loadWeather() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception("Location disabled");
      }

      var status = await Permission.location.request();
      if (!status.isGranted) {
        throw Exception("Permission denied");
      }

      Position pos = await Geolocator.getCurrentPosition();

      return await WeatherService().fetchWeather(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint("Weather error: $e");
      return {};
    }
  }

  Future<void> _loadDailyWater() async {
    final db = await DatabaseHelper.instance.database;

    // Get start of today
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM water WHERE date LIKE '$today%'",
    );

    setState(() {
      _dailyWater = (result.first['total'] ?? 0.0) as double;
    });
  }

  // Helper button widget
  Widget _waterButton(double ml, String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () async {
        await WaterService().logWater(ml); // The function we wrote earlier
        _loadDailyWater(); // Refresh the ring
        final waterSlider = Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.opacity),
              SizedBox(width: 10),
              Expanded(
                child: Slider(
                  value: 0,
                  max: 1.0,
                  min: 0.0,
                  onChanged: (value) {
                    setState(() {
                      waterLevel = value;
                      sphereBottleRef.currentState?.waterLevel = 0;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }

  // weekly chart
  List<double> _weeklyWaterData = [0, 0, 0, 0, 0, 0, 0];

  Future<void> _loadWeeklyData() async {
    final data = await DatabaseHelper.instance.getWeeklyWater();
    List<double> processedData = List.filled(7, 0.0);
    for (var entry in data) {
      int dayIndex = DateTime.parse(entry['day']).weekday - 1;
      processedData[dayIndex] = (entry['total'] as num).toDouble();
    }

    setState(() {
      _weeklyWaterData = processedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await NotificationService.scheduleNotification(
              id: 1,
              title: "Water drink",
              body: "Water a glass of water",
              scheduleTime: tz.TZDateTime.now(
                tz.local,
              ).add(const Duration(seconds: 10)),
            );
          },
          child: Icon(Icons.local_drink),
        ),
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Welcome, ${UserProfile.name}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, color: Colors.black),
            ),
            CircleAvatar(
              backgroundColor: Colors.indigo,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileSetupScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inside your Dashboard build method:
              Column(
                children: [
                  Text(
                    "Hydration Aura",
                    style: TextStyle(color: Colors.blueGrey[900], fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.shade100,
                          spreadRadius: 5,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: HydrationRing(
                      progress: UserProfile.waterGoal == 0
                          ? 0
                          : (UserProfile.drunkWater / UserProfile.waterGoal)
                                .clamp(0.0, 1.0),
                      currentAmount: UserProfile.drunkWater,
                      onWaterUpdated: (double p1) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _waterButton(250, "Glass", Icons.local_drink),
                      _waterButton(
                        500,
                        "Bottle",
                        CupertinoIcons.circle_bottomthird_split,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildReadinessCard(),
              const SizedBox(height: 25),

              const Text(
                "Today's Insights",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildLiveWeatherCard(), // Real-time data
                  _buildStatCard(
                    "Hydration",
                    "${UserProfile.drunkWater}L / ${UserProfile.waterGoal}L",
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    "Gym Goal",
                    "Chest Day",
                    Icons.fitness_center,
                    Colors.purple,
                  ),
                  _buildStatCard(
                    "Next Break",
                    "12:30 PM",
                    Icons.restaurant,
                    Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _buildPredictionChart(),
              // Inside your build method
              SizedBox(height: 20),
              ProgressPredictionChart(
                weeklyData: [1800, 3600, 2500, 1900, 5000, 2400], // Last 6 days
                prediction: 2450, // Calculated value
                goal: UserProfile.waterGoal, // 2500.0
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveWeatherCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            !snapshot.data!.containsKey("current_weather")) {
          return _buildStatCard(
            "Weather",
            "Unavailable",
            Icons.cloud_off,
            Colors.grey,
          );
        }

        final weather = snapshot.data!["current_weather"];
        final temp = weather["temperature"];
        final code = weather["weathercode"];

        return _buildStatCard(
          "Weather",
          "$temp°C",
          _getWeatherIcon(code),
          Colors.orange,
        );
      },
    );
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code < 3) return Icons.cloud_outlined;
    return Icons.umbrella;
  }

  Widget _buildReadinessCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Readiness Score",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "${score.toInt()}%", // Dynamic Percentage
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Perfect time for a high-intensity run!",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.bolt, color: Colors.yellow, size: 60),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GymTrackerScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Progress Prediction",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 1),
                      const FlSpot(1, 1.5),
                      const FlSpot(2, 1.4),
                      const FlSpot(3, 2.2),
                      const FlSpot(4, 2.1),
                      const FlSpot(5, 2.8), // This represents an upward trend
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
