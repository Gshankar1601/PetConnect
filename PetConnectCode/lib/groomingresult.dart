import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GroomingResultsScreen extends StatefulWidget {
  final String location;

  // ignore: prefer_const_constructors_in_immutables
  GroomingResultsScreen({required this.location});

  @override
  _GroomingResultsScreenState createState() => _GroomingResultsScreenState();
}

class _GroomingResultsScreenState extends State<GroomingResultsScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNearbyGroomingFacilities();
  }

  Future<void> _fetchNearbyGroomingFacilities() async {
    try {
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${widget.location}&format=json&limit=1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // ignore: unused_local_variable
        final lat = data[0]['lat'];
        // ignore: unused_local_variable
        final lon = data[0]['lon'];

        final query = '''
          [out:json];
          area["name"="Kerala"]->.boundary;
          (
            node["shop"="pet_grooming"](area.boundary);
            node["shop"="grooming"](area.boundary);
            node["amenity"="pet_service"](area.boundary);
          );
          out center;
        ''';

        final facilityResponse = await http.get(Uri.parse(
            'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}'));

        if (facilityResponse.statusCode == 200) {
          final facilities = json.decode(facilityResponse.body);

          List<Map<String, dynamic>> services = [];
          for (var facility in facilities['elements']) {
            final facilityLat = facility['lat'];
            final facilityLon = facility['lon'];
            final facilityName =
                facility['tags']['name'] ?? 'Unknown'; // Check for null

            // Reverse geocoding to get the address
            final addressResponse = await http.get(Uri.parse(
                'https://nominatim.openstreetmap.org/reverse?lat=$facilityLat&lon=$facilityLon&format=json&zoom=18&addressdetails=1'));

            if (addressResponse.statusCode == 200) {
              final addressData = json.decode(addressResponse.body);
              final address =
                  addressData['display_name'] ?? 'Unknown'; // Check for null
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
            _loading = false;
          });
        } else {
          print(
              'Failed to fetch grooming facilities: ${facilityResponse.statusCode}');
          setState(() {
            _loading = false;
          });
        }
      } else {
        print('Failed to geocode location: ${response.statusCode}');
        setState(() {
          _loading = false;
        });
      }
    } catch (error) {
      print('Error fetching grooming facilities: $error');
      setState(() {
        _loading = false;
      });
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
        title: Text('Grooming Services Nearby'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? Center(
                  child: Text('No grooming services found nearby.'),
                )
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
