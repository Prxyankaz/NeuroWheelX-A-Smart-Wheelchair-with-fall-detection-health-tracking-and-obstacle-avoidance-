import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Wheelchair',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 11, 5, 5),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref("fall_data");
  final DatabaseReference _healthDatabase = FirebaseDatabase.instance.ref("readings");

  Map<String, dynamic>? sensorData;
  double? heartRate;
  double? spo2;
  bool showFallMetrics = false;
  bool showHealthMetrics = false;

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
    _fetchHealthData();
  }

  void _fetchLatestData() {
    _database.orderByKey().limitToLast(1).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        final latestTimestamp = data.keys.first;
        final latestEntry = Map<String, dynamic>.from(data[latestTimestamp]);
        final uniqueKey = latestEntry.keys.first;

        setState(() {
          sensorData = Map<String, dynamic>.from(latestEntry[uniqueKey]);
        });
      }
    });
  }

  void _fetchHealthData() {
    _healthDatabase.orderByKey().limitToLast(1).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final healthData = event.snapshot.value as Map;
        final latestTimestamp = healthData.keys.first;

        if (healthData[latestTimestamp] is Map) {
          final latestEntry = Map<String, dynamic>.from(healthData[latestTimestamp]);

          setState(() {
            heartRate = latestEntry["heartRate"]?.toDouble();
            spo2 = latestEntry["SpO2"]?.toDouble();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 222, 243, 230),centerTitle: true,title: const Text("SMART WHEELCHAIR DASHBOARD")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 3, 48, 116), Color.fromARGB(255, 3, 6, 43)], // Dark blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            
          ),
        ),
        child: Center(
          child: sensorData == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToggleCard(
                      title: "Fall Metrics",
                      icon: Icons.warning,
                      showContent: showFallMetrics,
                      onTap: () => setState(() => showFallMetrics = !showFallMetrics),
                      content: showFallMetrics
                          ? [
                              "Acceleration (m/s²)",
                              "X: ${sensorData!["accel_x"]}",
                              "Y: ${sensorData!["accel_y"]}",
                              "Z: ${sensorData!["accel_z"]}",
                              "",
                              "Gyroscope (rad/s)",
                              "X: ${sensorData!["gyro_x"]}",
                              "Y: ${sensorData!["gyro_y"]}",
                              "Z: ${sensorData!["gyro_z"]}",
                            ]
                          : [],
                    ),
                    _buildToggleCard(
                      title: "Health Metrics",
                      icon: Icons.favorite,
                      showContent: showHealthMetrics,
                      onTap: () => setState(() => showHealthMetrics = !showHealthMetrics),
                      content: showHealthMetrics
                          ? [
                              "Heart Rate: ${heartRate?.toStringAsFixed(2) ?? 'N/A'} BPM",
                              "SpO₂: ${spo2?.toStringAsFixed(2) ?? 'N/A'} %",
                            ]
                          : [],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (sensorData!["fall_alert"] == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FallLocationScreen(sensorData: sensorData!),
                            ),
                          );
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        color: sensorData!["fall_alert"] == true ? Colors.red : Colors.green,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                sensorData!["fall_alert"] == true ? Icons.warning : Icons.check_circle,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                sensorData!["fall_alert"] == true
                                    ? "Fall Detected! Tap for location"
                                    : "No Fall Detected",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required IconData icon,
    required bool showContent,
    required VoidCallback onTap,
    required List<String> content,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, size: 30, color: const Color.fromARGB(255, 226, 19, 19)),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (showContent)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content.map((value) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FallLocationScreen extends StatelessWidget {
  final Map<String, dynamic> sensorData;
  const FallLocationScreen({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    double latitude = sensorData["latitude"];
    double longitude = sensorData["longitude"];

    return Scaffold(
      appBar: AppBar(title: const Text("Fall Location")),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(latitude, longitude),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 50.0,
                height: 50.0,
                point: LatLng(latitude, longitude),
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
