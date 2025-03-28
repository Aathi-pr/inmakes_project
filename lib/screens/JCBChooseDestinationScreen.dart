import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juber_car_booking/screens/driver_screens/JCBDriverHomeScreen.dart';
import 'package:location/location.dart' as loc;
import 'package:nb_utils/nb_utils.dart';
import 'package:juber_car_booking/screens/JCBBookRideScreen.dart';
import 'package:juber_car_booking/utils/JBCColors.dart';
import 'package:juber_car_booking/utils/JCBCommon.dart';
import 'package:juber_car_booking/utils/JCBConstants.dart';
import 'package:juber_car_booking/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class JCBChooseDestinationScreen extends StatefulWidget {
  final LatLng? destinationAddress;
  final LatLng? currentAddress;

  JCBChooseDestinationScreen({this.destinationAddress, this.currentAddress});

  @override
  _JCBChooseDestinationScreenState createState() =>
      _JCBChooseDestinationScreenState();
}

class _JCBChooseDestinationScreenState
    extends State<JCBChooseDestinationScreen> {
  String LatLngsToString(LatLng? LatLng) {
    if (LatLng == null) return 'Location not Found';
    return '${LatLng.latitude}, ${LatLng.longitude}';
  }

  late GoogleMapController mapController;
  final LatLng _center = const LatLng(10.8505, 76.2711);
  LatLng? currentLatLng;
  LatLng? destinationLatLng;
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getCoordinates();
  }

  Future<void> _getCoordinates() async {
    if (widget.currentAddress != null) {
      currentLatLng = widget.currentAddress;
    }
    if (widget.destinationAddress != null) {
      destinationLatLng = widget.destinationAddress;
    }

    if (currentLatLng != null && destinationLatLng != null) {
      _addMarkers();
      await _addPolyline();
    }
  }

  Future<String?> _getAddressFromLatLng(LatLng? LatLng) async {
    if (LatLng == null) return 'Unknown Location';
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(LatLng.latitude, LatLng.longitude);
      Placemark placemark = placemarks.first;
      return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
    } catch (e) {
      return 'Location not found';
    }
  }

  void _addMarkers() {
    markers.clear();

    if (currentLatLng != null) {
      markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: currentLatLng!,
          infoWindow: InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    }

    if (destinationLatLng != null) {
      markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: destinationLatLng!,
          infoWindow: InfoWindow(title: 'Destination'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    setState(() {});
  }

  Future<void> _addPolyline() async {
    if (currentLatLng == null || destinationLatLng == null) {
      debugPrint('Missing current or destination location');
      return;
    }

    const String apiKey = 'AIzaSyBY5ROTpGoeYZAX5l1gC1eDGOmzUimJqD0';
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLatLng!.latitude},${currentLatLng!.longitude}&destination=${destinationLatLng!.latitude},${destinationLatLng!.longitude}&key=$apiKey';

    debugPrint('Requesting Route: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Print API response
        debugPrint('API Response: ${jsonEncode(data)}');

        if (data['routes'].isNotEmpty) {
          String encodedPolyline =
              data['routes'][0]['overview_polyline']['points'];
          List<LatLng> routePoints = _decodePolyline(encodedPolyline);

          debugPrint('Decoded Polyline: ${routePoints.length} points');

          setState(() {
            polylines.clear();
            polylines.add(
              Polyline(
                polylineId: PolylineId('route'),
                points: routePoints,
                color: Colors.blue,
                width: 5,
              ),
            );
          });
        } else {
          debugPrint('No routes found in API response.');
        }
      } else {
        debugPrint(
            'Failed to load route: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLatLng != null) {
      mapController
          .animateCamera(CameraUpdate.newLatLngZoom(currentLatLng!, 12));
    }
  }

  @override
  Widget build(BuildContext context) {
    log('destination : ${widget.destinationAddress}');

    return Scaffold(
      appBar: AppBar(
        leading: jcbBackWidget(context),
        centerTitle: true,
        title: FutureBuilder(
            future: _getAddressFromLatLng(widget.destinationAddress!),
            builder: (context, data) {
              if (data.connectionState == ConnectionState.waiting) {
                return Text(
                  'Fetching Address..',
                  style: boldTextStyle(),
                );
              } else if (data.hasError) {
                return Text(
                  'Location Not Found!',
                  style: boldTextStyle(),
                );
              } else {
                return Text(
                  data.data ?? 'choose your destination',
                  style: boldTextStyle(),
                );
              }
            }),
        actions: [
          Image.asset(
            'images/juberCarBooking/jcbIcons/ic_search.png',
            height: 24,
            width: 24,
            fit: BoxFit.cover,
            color: jcbSecBorderColor,
          ).paddingAll(16),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GoogleMap(
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers: markers,
            polylines: polylines,
          ),
          Container(
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius: radiusOnly(
                topLeft: jcbBottomSheetRadius,
                topRight: jcbBottomSheetRadius,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose a Destination',
                  style: boldTextStyle(
                    size: 26,
                    fontFamily: jcbFont,
                    color: appStore.isDarkModeOn ? Colors.white : jcbDarkColor,
                    weight: FontWeight.w900,
                  ),
                ),
                16.height,
                Text(
                  'Please select a valid destination location on the map',
                  style: secondaryTextStyle(color: context.iconColor),
                ),
                16.height,
                AppButton(
                  width: context.width() - 32,
                  child: Text(
                    'Set Destination'.toUpperCase(),
                    style: boldTextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    if (currentLatLng != null && destinationLatLng != null) {
                      JCBBookRideScreen(
                              currentLocation: currentLatLng!,
                              destination: destinationLatLng!)
                          .launch(context);
                    } else {
                      toast('Please Select a Valid Deatination');
                    }
                  },
                  color: jcbPrimaryColor,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: radius(jcbButtonRadius)),
                  elevation: 0,
                ),
                16.height,
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 210,
            child: Container(
              decoration: BoxDecoration(
                color: context.scaffoldBackgroundColor,
                borderRadius: radius(8),
              ),
              child: IconButton(
                icon: Image.asset(
                  'images/juberCarBooking/jcbIcons/ic_navigation.png',
                  height: 20,
                  width: 20,
                  fit: BoxFit.cover,
                ),
                onPressed: () {
                  JCBBookRideScreen(
                          currentLocation: currentLatLng!,
                          destination: destinationLatLng!)
                      .launch(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
