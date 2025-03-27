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
        scaffoldBackgroundColor: Colors.grey[200],
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
  final DatabaseReference _healthDatabase = FirebaseDatabase.instance.ref("health_metrics");
  Map<String, dynamic>? sensorData;
  double? heartRate;

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
  }

  void _fetchLatestData() {
    // Fetch fall detection data
    _database.orderByKey().limitToLast(1).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map;
        final String latestTimestamp = data.keys.first;
        final Map<String, dynamic> latestEntry = Map<String, dynamic>.from(data[latestTimestamp]);
        final String uniqueKey = latestEntry.keys.first;
        
        setState(() {
          sensorData = Map<String, dynamic>.from(latestEntry[uniqueKey]);
        });
      }
    });

    // Fetch heart rate data
    _healthDatabase.orderByKey().limitToLast(1).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> healthData = event.snapshot.value as Map;
        final String latestTimestamp = healthData.keys.first;
        setState(() {
          heartRate = (healthData[latestTimestamp]["heartRate"] as num).toDouble();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Wheelchair Dashboard")),
      body: Center(
        child: sensorData == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMetricCard("Acceleration (m/s²)", Icons.speed, [
                    "X: ${sensorData!["accel_x"]}",
                    "Y: ${sensorData!["accel_y"]}",
                    "Z: ${sensorData!["accel_z"]}"
                  ]),
                  _buildMetricCard("Gyroscope (rad/s)", Icons.sync, [
                    "X: ${sensorData!["gyro_x"]}",
                    "Y: ${sensorData!["gyro_y"]}",
                    "Z: ${sensorData!["gyro_z"]}"
                  ]),
                  _buildMetricCard(
                    "Heart Rate (BPM)",
                    Icons.favorite,
                    ["${heartRate?.toStringAsFixed(2) ?? 'N/A'}"],
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
                              sensorData!["fall_alert"] == true ? "Fall Detected! Tap for location" : "No Fall Detected",
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
    );
  }

  Widget _buildMetricCard(String title, IconData icon, List<String> values) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                for (var value in values)
                  Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ],
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
                child: const Icon(  
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
