import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juber_car_booking/components/JCBDriverDrawerComponent.dart';
import 'package:location/location.dart' as loc;

class JCBDriverHomeScreen extends StatefulWidget {
  const JCBDriverHomeScreen({super.key});

  @override
  State<JCBDriverHomeScreen> createState() => _JCBDriverHomeScreenState();
}

class _JCBDriverHomeScreenState extends State<JCBDriverHomeScreen> {
  GoogleMapController? _mapController;
  loc.Location _location = loc.Location();
  LatLng? _currentLocation;
  bool _isRideActive = false;
  bool _showBottomSheet = false;
  Map<String, dynamic>? _currentRequest;

  // Fetching Current Location
  Future<void> _getCurrentLocation() async {
    try {
      loc.LocationData locationData = await _location.getLocation();
      setState(() {
        _currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _requestedRide() {
    FirebaseFirestore.instance
        .collection('rideRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic>? requestData = snapshot.docs.first.data();
        String? pickupAddress = await _getAddressFromLatLng(
          requestData['currentLocation']['latitude'],
          requestData['currentLocation']['logitude'],
        );
        String? dropoffAddress = await _getAddressFromLatLng(
          requestData['destinationLocation']['latitude'],
          requestData['destinationLocation']['logitude'],
        );
        setState(() {
          _currentRequest = {
            ...requestData,
            'pickupAddress': pickupAddress,
            'dropoffAddress': dropoffAddress
          };
          _showBottomSheet = true;
        });
      } else {
        setState(() {
          _currentRequest = null;
          _showBottomSheet = false;
        });
      }
    });
  }

  void _updateRideStatus(String newStatus) {
    if (_currentRequest != null) {
      FirebaseFirestore.instance
          .collection('rideRequests')
          .doc(_currentRequest!['requestID'])
          .update({'status': newStatus}).then((_) {
        setState(() {
          _showBottomSheet = false;
          _currentRequest = null;
        });
      }).catchError((error) {
        print('Error updating ride status: $error');
      });
    }
  }

  Future<String?> _getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.country ?? ''}';
      }
      return 'Unknown Location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Location not Found';
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _requestedRide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Home"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: JCBDriverDrawerComponent(),
      endDrawerEnableOpenDragGesture: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: _currentLocation == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: _currentLocation!, zoom: 13),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _currentRequest != null
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              spreadRadius: 2)
                        ]),
                    child: Column(
                      children: [
                        const Text('New Ride Requests',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          "Pickup: ${_currentRequest?['pickupAddress'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Drop Off: ${_currentRequest?['dropoffAddress'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              onPressed: () {
                                _updateRideStatus('Accepted');
                              },
                              child: const Text("ACCEPT",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              onPressed: () {
                                _updateRideStatus('Rejected');
                              },
                              child: const Text("REJECT",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
