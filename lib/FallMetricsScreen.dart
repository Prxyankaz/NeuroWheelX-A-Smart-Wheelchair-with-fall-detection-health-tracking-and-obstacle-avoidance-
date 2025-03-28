class FallMetricsScreen extends StatelessWidget {
  final Map<String, dynamic> sensorData;
  const FallMetricsScreen({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fall Metrics")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildMetricCard("Acceleration (m/s²)", Icons.speed, [
              "X: ${sensorData["accel_x"]}",
              "Y: ${sensorData["accel_y"]}",
              "Z: ${sensorData["accel_z"]}"
            ]),
            _buildMetricCard("Gyroscope (rad/s)", Icons.sync, [
              "X: ${sensorData["gyro_x"]}",
              "Y: ${sensorData["gyro_y"]}",
              "Z: ${sensorData["gyro_z"]}"
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, IconData icon, List<String> values) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 35, color: Colors.blueAccent),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                for (var value in values)
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
