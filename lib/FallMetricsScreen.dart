import 'package:flutter/material.dart';

class FallMetricsScreen extends StatelessWidget {
  final Map<String, dynamic> sensorData;

  const FallMetricsScreen({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fall Metrics"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricCard("Acceleration", Icons.speed, [
              "X: \${sensorData["accel_x"] ?? "N/A"}",
              "Y: \${sensorData["accel_y"] ?? "N/A"}",
              "Z: \${sensorData["accel_z"] ?? "N/A"}",
            ]),
            const SizedBox(height: 20),
            _buildMetricCard("Gyroscope", Icons.rotate_right, [
              "X: \${sensorData["gyro_x"] ?? "N/A"}",
              "Y: \${sensorData["gyro_y"] ?? "N/A"}",
              "Z: \${sensorData["gyro_z"] ?? "N/A"}",
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, IconData icon, List<String> values) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                for (var value in values)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}