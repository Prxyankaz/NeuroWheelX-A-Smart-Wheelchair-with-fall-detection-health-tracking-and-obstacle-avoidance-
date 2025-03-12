import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FallLocationScreen extends StatelessWidget {
  final Map<String, dynamic> sensorData;

  const FallLocationScreen({super.key, required this.sensorData});

  @override
  Widget build(BuildContext context) {
    double latitude = sensorData["latitude"] ?? 0.0;
    double longitude = sensorData["longitude"] ?? 0.0;

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
                point: LatLng(latitude, longitude),
                width: 80,
                height: 80,
                child:const Icon(
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
