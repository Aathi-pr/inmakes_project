import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:juber_car_booking/components/JCBAlertDialogComponent.dart';
import 'package:juber_car_booking/components/JCBCancelBookingComponent.dart';
import 'package:juber_car_booking/components/JCBDrawerComponent.dart';
import 'package:juber_car_booking/components/JCBFoundDriverComponent.dart';
import 'package:juber_car_booking/components/JCBRideTypeComponent.dart';
import 'package:juber_car_booking/models/JCBRideModel.dart';
import 'package:juber_car_booking/screens/JCBSuggestedRidesScreen.dart';
import 'package:juber_car_booking/utils/JBCColors.dart';
import 'package:juber_car_booking/utils/JCBConstants.dart';
import 'package:juber_car_booking/main.dart';

// ignore: must_be_immutable

final GlobalKey<ScaffoldState> jcbRideKey = GlobalKey();

class JCBBookRideScreen extends StatefulWidget {
  final LatLng currentLocation;
  final LatLng destination;

  JCBBookRideScreen({required this.currentLocation, required this.destination});
  @override
  State<JCBBookRideScreen> createState() => _JCBBookRideScreenState();
}

class _JCBBookRideScreenState extends State<JCBBookRideScreen> {
  late GoogleMapController mapController;
  LatLng? currentLatLng;
  LatLng? destinationLatLng;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<String?> _getAddressFromLatLng(LatLng? latLng) async {
    if (latLng == null) return 'Unknown Location';
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      Placemark placemark = placemarks.first;
      return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
    } catch (e) {
      return 'Location not found';
    }
  }

  Future<void> createRideRequest({
    required LatLng currentLocation,
    required LatLng destinationLocation,
    String? driverID,
  }) async {
    try {
      String userID = FirebaseAuth.instance.currentUser?.uid ?? '';
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userID).get();
      if (!userSnapshot.exists) {
        throw Exception('user not found');
      }
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      DocumentReference rideReference =
          _firestore.collection('rideRequests').doc();
      await rideReference.set({
        'requestID': rideReference.id,
        'userName': userData['firstName'],
        'userPhone': userData['phone'],
        'email': userData['email'],
        'currentLocation': {
          'latitude': currentLocation.latitude,
          'logitude': currentLocation.longitude,
        },
        'destinationLocation': {
          'latitude': destinationLocation.latitude,
          'logitude': destinationLocation.longitude
        },
        'requestDate': FieldValue.serverTimestamp(),
        'driverID': driverID ?? '',
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('Erorr $e');
    }
  }

  List<JCBRideModel> rideList = getRideTypes().sublist(0, 2);

  bool showLoader = false;
  bool showBottomSheet = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: jcbRideKey,
      drawer: JCBDrawerComponent(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GoogleMap(
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.currentLocation,
              zoom: 11.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('current Location'),
                position: widget.currentLocation,
              ),
              Marker(
                markerId: MarkerId('destination'),
                position: widget.destination,
              ),
            },
          ),
          Positioned(
            top: context.statusBarHeight + 20,
            left: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.scaffoldBackgroundColor,
                    borderRadius: radius(jcbButtonRadius),
                  ),
                  child: FutureBuilder<List<String?>>(
                    future: Future.wait([
                      _getAddressFromLatLng(widget.currentLocation),
                      _getAddressFromLatLng(widget.destination),
                    ]),
                    builder: (context, snapshot) {
                      String startAddress =
                          snapshot.hasData && snapshot.data![0] != null
                              ? snapshot.data![0]!
                              : "Fetching address...";

                      String endAddress =
                          snapshot.hasData && snapshot.data![1] != null
                              ? snapshot.data![1]!
                              : "Fetching destination...";

                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: boldTextStyle(),
                          children: [
                            TextSpan(text: startAddress),
                            WidgetSpan(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Icon(Icons.arrow_forward,
                                    color: jcbGreyColor, size: 18),
                              ),
                            ),
                            TextSpan(text: endAddress),
                          ],
                        ),
                      );
                    },
                  ),
                ).expand(),
                16.width,
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: context.scaffoldBackgroundColor, width: 2),
                    borderRadius: radius(100),
                  ),
                  child: Image.asset(
                    'images/juberCarBooking/jcb_face2.jpg',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ).cornerRadiusWithClipRRect(100).onTap(() {
                    jcbRideKey.currentState!.openDrawer();
                  }, borderRadius: radius(100)),
                )
              ],
            ),
          ),
          showLoader
              ? Container(
                  width: context.width(),
                  decoration: BoxDecoration(
                      color: context.scaffoldBackgroundColor,
                      borderRadius: radiusOnly(
                          topLeft: jcbBottomSheetRadius,
                          topRight: jcbBottomSheetRadius)),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'images/juberCarBooking/jcbGifs/jcb_loader.gif',
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        'We are processing your booking...'.toUpperCase(),
                        style: boldTextStyle(
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : jcbDarkColor),
                      ),
                      8.height,
                      Text('Your ride will start soon',
                          style: secondaryTextStyle(color: jcbGreyColor)),
                      20.height,
                    ],
                  ),
                )
              : Container(
                  height: 280,
                  width: context.width(),
                  decoration: BoxDecoration(
                    color: context.scaffoldBackgroundColor,
                    borderRadius: radiusOnly(
                        topLeft: jcbBottomSheetRadius,
                        topRight: jcbBottomSheetRadius),
                  ),
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SUGGESTED RIDES',
                          style: boldTextStyle(
                            size: 20,
                            fontFamily: jcbFont,
                            color: appStore.isDarkModeOn
                                ? Colors.white
                                : jcbDarkColor,
                            weight: FontWeight.w900,
                          ),
                        ),
                        8.height,
                        JCBRideComponent(rideList: rideList),
                        Divider(color: jcbSecBorderColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: boldTextStyle(
                                    color: appStore.isDarkModeOn
                                        ? Colors.white
                                        : jcbDarkColor),
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.monetization_on,
                                        color: appStore.isDarkModeOn
                                            ? Colors.white
                                            : jcbDarkColor,
                                        size: 18),
                                  ),
                                  TextSpan(text: 'Cash payment'),
                                  WidgetSpan(
                                    child: Icon(Icons.arrow_forward_ios,
                                        color: appStore.isDarkModeOn
                                            ? Colors.white
                                            : jcbDarkColor,
                                        size: 18),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Promo',
                                    style: secondaryTextStyle(
                                        color: context.iconColor)),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: jcbSecBorderColor,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                ),
                                Icon(Icons.calendar_today_outlined,
                                    color: context.iconColor, size: 16),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: jcbSecBorderColor,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                ),
                                Icon(Icons.edit,
                                    color: context.iconColor, size: 16)
                              ],
                            ),
                          ],
                        ),
                        16.height,
                      ],
                    ),
                  ),
                ),
          Positioned(
            right: 16,
            bottom: showLoader ? 200 : 300,
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
                    fit: BoxFit.cover),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: showLoader
          ? Dismissible(
              key: Key(''),
              child: Container(
                decoration: BoxDecoration(
                    color: jcbGreyColor.withAlpha(80),
                    borderRadius: radius(50)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.cancel, size: 40, color: Colors.white),
                    Text('Slide to cancel'.toUpperCase(),
                        style: boldTextStyle(color: Colors.white, size: 18)),
                    16.width,
                  ],
                ),
              ),
              onDismissed: (_) {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    enableDrag: true,
                    isDismissible: false,
                    shape: RoundedRectangleBorder(
                        borderRadius: radiusOnly(topLeft: 30, topRight: 30)),
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JCBCancelBookingComponent(),
                          16.height,
                          AppButton(
                            width: context.width() - 32,
                            child: Text('Keep the booking'.toUpperCase(),
                                style: boldTextStyle(color: Colors.white)),
                            onTap: () {
                              finish(context);
                            },
                            color: jcbPrimaryColor,
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius: radius(jcbButtonRadius)),
                            elevation: 0,
                          ),
                          8.height,
                          AppButton(
                            width: context.width() - 32,
                            child: Text('cancel ride'.toUpperCase(),
                                style: boldTextStyle(color: jcbPrimaryColor)),
                            onTap: () {
                              showLoader = false;
                              showBottomSheet = false;
                              setState(() {});
                              finish(context);
                            },
                            color: context.scaffoldBackgroundColor,
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: radius(jcbButtonRadius),
                              side: BorderSide(color: jcbPrimaryColor),
                            ),
                            elevation: 0,
                          ),
                          16.height,
                        ],
                      );
                    });
              },
            ).paddingSymmetric(horizontal: 16, vertical: 16)
          : AppButton(
              child: Text('Book Now'.toUpperCase(),
                  style: boldTextStyle(color: Colors.white)),
              onTap: () {
                createRideRequest(
                    currentLocation: widget.currentLocation,
                    destinationLocation: widget.destination);
                JCBSuggestedRidesScreen().launch(context).then((value) async {
                  showLoader = true;
                  setState(() {});

                  await Future.delayed(Duration(seconds: 5))
                      .then((value) async {
                    showLoader = false;
                    setState(() {});

                    if (showBottomSheet) {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          enableDrag: true,
                          isDismissible: false,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  radiusOnly(topLeft: 30, topRight: 30)),
                          builder: (context) {
                            return JCBFoundDriverComponent();
                          });

                      await Future.delayed(Duration(seconds: 3)).then((value) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: JCBAlertDialogComponent(),
                            );
                          },
                        );
                      });
                    } else {
                      showBottomSheet = true;
                      setState(() {});
                    }
                  });
                });
              },
              color: jcbPrimaryColor,
              elevation: 0,
              shapeBorder:
                  RoundedRectangleBorder(borderRadius: radius(jcbButtonRadius)),
            ).paddingOnly(left: 16, right: 16, bottom: 16),
    );
  }
}
