import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HealthResultsScreen extends StatefulWidget {
  final String location;

  HealthResultsScreen({required this.location});

  @override
  _HealthResultsScreenState createState() => _HealthResultsScreenState();
}

class _HealthResultsScreenState extends State<HealthResultsScreen> {
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchNearbyHealthFacilities();
  }

  Future<void> _fetchNearbyHealthFacilities() async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${widget.location}&format=json&limit=1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lat = data[0]['lat'];
        final lon = data[0]['lon'];

        final facilityResponse = await http.get(Uri.parse(
            'https://overpass-api.de/api/interpreter?data=[out:json];node(around:10000,$lat,$lon)["amenity"="veterinary"];out 10;'));

        if (facilityResponse.statusCode == 200) {
          final facilities = json.decode(facilityResponse.body);

          List<Map<String, dynamic>> services = [];
          for (var facility in facilities['elements']) {
            final facilityLat = facility['lat'];
            final facilityLon = facility['lon'];
            final facilityName = facility['tags']['name'];

            // Reverse geocoding to get the address
            final addressResponse = await http.get(Uri.parse(
                'https://nominatim.openstreetmap.org/reverse?lat=$facilityLat&lon=$facilityLon&format=json&zoom=18&addressdetails=1'));

            if (addressResponse.statusCode == 200) {
              final addressData = json.decode(addressResponse.body);
              final address = addressData['display_name'];
              services.add({
                'name': facilityName,
                'address': address,
                'lat': facilityLat,
                'lon': facilityLon,
              });
            } else {
              print(
                  'Failed to fetch address for facility: ${facility['tags']['name']}');
            }
          }

          setState(() {
            _services = services;
          });
        } else {
          print(
              'Failed to fetch health facilities: ${facilityResponse.statusCode}');
        }
      } else {
        print('Failed to geocode location: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching health facilities: $error');
      // Handle error
    }
  }

  // Function to open Google Maps with the provided location
  Future<void> _openGoogleMaps(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Services Nearby'),
      ),
      body: _services.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final facility = _services[index];
                return ListTile(
                  title: Text(facility['name']),
                  subtitle: Text(facility['address']),
                  trailing: IconButton(
                    icon: Icon(Icons.directions),
                    onPressed: () {
                      _openGoogleMaps(facility['lat'], facility['lon']);
                    },
                  ),
                );
              },
            ),
    );
  }
}
