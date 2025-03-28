import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:juber_car_booking/components/JCBDrawerComponent.dart';
import 'package:juber_car_booking/screens/JCBSearchDestinationScreen.dart';
import 'package:juber_car_booking/utils/JBCColors.dart';
import 'package:juber_car_booking/utils/JCBConstants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juber_car_booking/main.dart';

final GlobalKey<ScaffoldState> jcbHomeKey = GlobalKey();

class JCBHomeScreen extends StatefulWidget {
  @override
  _JCBHomeScreenState createState() => _JCBHomeScreenState();
}

class _JCBHomeScreenState extends State<JCBHomeScreen> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _currentLocation = null;

  Map<PolylineId, Polyline> polylines = {};

  final LatLng _center = const LatLng(10.8505, 76.2711);
  final LatLng destinationLocation = LatLng(9.9816, 76.2999);

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  Future<LatLng?> getLocationUpdates() async {
    bool _isServiceEnabled;
    PermissionStatus _isPermissionGranted;

    _isServiceEnabled = await _locationController.serviceEnabled();
    if (!_isServiceEnabled) {
      _isServiceEnabled = await _locationController.requestService();
      if (!_isServiceEnabled) return null;
    }

    _isPermissionGranted = await _locationController.hasPermission();
    if (_isPermissionGranted == PermissionStatus.denied ||
        _isPermissionGranted == PermissionStatus.deniedForever) {
      _isPermissionGranted = await _locationController.requestPermission();
      if (_isPermissionGranted != PermissionStatus.granted) return null;
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentLocation =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentLocation!);
        });
      }
    });

    LocationData? currentLocation = await _locationController.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      return LatLng(currentLocation.latitude!, currentLocation.longitude!);
    }

    return null;
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: jcbHomeKey,
      drawer: JCBDrawerComponent(),
      body: _currentLocation == null
          ? const Center(
              child: Text('Loading...'),
            )
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                GoogleMap(
                  onMapCreated: ((GoogleMapController controller) =>
                      _mapController.complete(controller)),
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 11.0,
                  ),
                  markers: {
                    if (_currentLocation != null)
                      Marker(
                          markerId: MarkerId('_currentLocation'),
                          position: _currentLocation!,
                          icon: BitmapDescriptor.defaultMarker),
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: context.scaffoldBackgroundColor,
                    borderRadius: radiusOnly(
                        topLeft: jcbBottomSheetRadius,
                        topRight: jcbBottomSheetRadius),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Where are you going?',
                        style: boldTextStyle(
                          size: 26,
                          fontFamily: jcbFont,
                          color: appStore.isDarkModeOn
                              ? Colors.white
                              : jcbDarkColor,
                          weight: FontWeight.w900,
                        ),
                      ),
                      16.height,
                      Text('Book on demand or pre-schedule rides',
                          style: secondaryTextStyle(color: context.iconColor)),
                      16.height,
                      Container(
                        padding: EdgeInsets.only(left: 16),
                        decoration: BoxDecoration(
                          borderRadius: radius(jcbButtonRadius),
                          border: Border.all(
                              color: appStore.isDarkModeOn
                                  ? context.dividerColor
                                  : jcbSecBorderColor),
                        ),
                        child: AppTextField(
                          autoFocus: false,
                          textFieldType: TextFieldType.NAME,
                          textStyle: boldTextStyle(),
                          onChanged: (val) {
                            hideKeyboard(context);
                            JCBSearchDestinationScreen().launch(context);
                          },
                          onTap: () async {
                            hideKeyboard(context);
                            LatLng? currentLocationToSearchDeastinationScreen =
                                await getLocationUpdates();
                            if (currentLocationToSearchDeastinationScreen !=
                                null) {
                              JCBSearchDestinationScreen(
                                      currentAddress:
                                          currentLocationToSearchDeastinationScreen)
                                  .launch(context);
                            } else {
                              toast('Unable to Get Location.');
                            }
                          },
                          decoration: InputDecoration(
                            suffixIcon: Image.asset(
                              'images/juberCarBooking/jcbIcons/ic_search.png',
                              height: 14,
                              width: 14,
                              fit: BoxFit.cover,
                              color: jcbPrimaryColor,
                            ).paddingAll(12),
                            border: InputBorder.none,
                            hintText: 'Enter Destination',
                            hintStyle: boldTextStyle(color: jcbGreyColor),
                          ),
                        ),
                      ),
                      16.height,
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 200,
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
                        JCBSearchDestinationScreen().launch(context);
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: context.statusBarHeight + 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: radius(100),
                      border: Border.all(
                          color: context.scaffoldBackgroundColor, width: 2),
                    ),
                    child: Image.asset(
                      'images/juberCarBooking/jcb_face2.jpg',
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(100).onTap(() {
                      jcbHomeKey.currentState!.openDrawer();
                    }, borderRadius: radius(100)),
                  ),
                )
              ],
            ),
    );
  }
}
