import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:juber_car_booking/components/JCBDestinationWidget.dart';
import 'package:juber_car_booking/models/JCBSearchDestinationModel.dart';
import 'package:juber_car_booking/screens/JCBChooseDestinationScreen.dart';
import 'package:juber_car_booking/screens/JCBFavouriteScreen.dart';
import 'package:juber_car_booking/utils/JBCColors.dart';
import 'package:juber_car_booking/utils/JCBCommon.dart';
import 'package:juber_car_booking/utils/JCBConstants.dart';
import 'package:juber_car_booking/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore: must_be_immutable
class JCBSearchDestinationScreen extends StatefulWidget {
  final LatLng? currentAddress;
  JCBSearchDestinationScreen({this.currentAddress});
  @override
  State<JCBSearchDestinationScreen> createState() =>
      _JCBSearchDestinationScreenState();
}

class _JCBSearchDestinationScreenState
    extends State<JCBSearchDestinationScreen> {
  List<JCBSearchDestinationModel> destinationList = jcbDestinationsList();

  TextEditingController destination = TextEditingController();
  List<String> searchResults = [];
  List<String> addedDestinations = [];

  bool showAdd = false;

  // converting Address from latLng
  Future<String> reverseGeocodeLatLng(LatLng? latlng) async {
    if (latlng == null) return 'Error Finding Location.';
    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(latlng.latitude, latlng.longitude);
      Placemark place = placemark.first;
      print('${place.name}');
      return '${place.street} ${place.locality}, ${place.country}';
    } catch (e) {
      return e.toString();
    }
  }

  //converting latlng to address
  Future<LatLng?> reverseGeocodeAddress(String address) async {
    try {
      List<Location> location = await locationFromAddress(address);
      if (location.isNotEmpty) {
        return LatLng(location.first.latitude, location.first.longitude);
      }
    } catch (e) {
      debugPrint("Reverse Geocode Error: $e");
    }
    return null;
  }

  //google places suggetions
  static Future<List<String>> getPlaceSuggestions(String input) async {
    const String apiKey = 'AIzaSyBY5ROTpGoeYZAX5l1gC1eDGOmzUimJqD0';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:IN');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> suggestions = [];

      if (data['status'] == 'OK') {
        for (var place in data['predictions']) {
          suggestions.add(place['description']);
        }
      }
      return suggestions;
    } else {
      return [];
    }
  }

  void searchLocation(String query) async {
    if (query.isNotEmpty) {
      List<String> results = await getPlaceSuggestions(query);
      setState(() {
        searchResults = results;
      });
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  Widget getDesWidget() {
    if (addedDestinations.isEmpty) {
      return Offstage();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: addedDestinations.map((e) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(e, style: boldTextStyle()),
                  Icon(Icons.cancel, color: jcbSecBorderColor, size: 20)
                      .onTap(() {
                    addedDestinations.remove(e);
                    setState(() {});
                  }),
                ],
              ),
              Divider(color: jcbSecBorderColor),
            ],
          );
        }).toList(),
      );
    }
  }

  Widget getDottedLine() {
    if (addedDestinations.isEmpty) {
      return Offstage();
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: addedDestinations.map((e) {
          return Column(
            children: [
              Icon(Icons.square, color: jcbPrimaryColor, size: 16),
              jcbDottedLineComponent(height: 22),
            ],
          );
        }).toList(),
      );
    }
  }

  @override
  void dispose() {
    addedDestinations.clear();
    super.dispose();
  }

  String? currentAddress;

  @override
  void initState() {
    super.initState();
    if (widget.currentAddress != null) {
      reverseGeocodeLatLng(widget.currentAddress!).then((address) => {
            setState(() {
              currentAddress = address;
            })
          });
    } else {
      currentAddress = 'Current Location not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'images/juberCarBooking/jcbIcons/ic_close.png',
            height: 20,
            width: 20,
            fit: BoxFit.cover,
            color: context.iconColor,
          ),
          onPressed: () {
            finish(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              JCBChooseDestinationScreen().launch(context);
            },
            icon: Icon(Icons.map_outlined, color: context.iconColor, size: 26),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.scaffoldBackgroundColor,
                borderRadius: radiusOnly(
                    bottomLeft: jcbBottomSheetRadius,
                    bottomRight: jcbBottomSheetRadius),
                boxShadow: [
                  BoxShadow(
                    color:
                        appStore.isDarkModeOn ? context.cardColor : Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Icon(Icons.circle, color: context.iconColor, size: 14),
                      jcbDottedLineComponent(height: 22),
                      getDottedLine(),
                      Icon(Icons.square, color: jcbPrimaryColor, size: 16),
                    ],
                  ),
                  8.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currentAddress ?? 'Fetching Address..',
                          style: boldTextStyle()),
                      Divider(color: jcbSecBorderColor),
                      getDesWidget(),
                      TextField(
                        controller: destination,
                        onChanged: (val) => searchLocation(val),
                        decoration: InputDecoration(
                          hintText: 'Enter Destination',
                        ),
                      ),
                      16.height,
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: AppButton(
                          child: Text(
                            'Choose'.toUpperCase(),
                            style: boldTextStyle(color: Colors.white),
                          ),
                          onTap: () async {
                            if (destination.text.isNotEmpty) {
                              LatLng? destinationLatLng =
                                  await reverseGeocodeAddress(destination.text);
                              if (destinationLatLng != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            JCBChooseDestinationScreen(
                                                currentAddress:
                                                    widget.currentAddress,
                                                destinationAddress:
                                                    destinationLatLng)));
                              }
                            }
                          },
                          color: jcbPrimaryColor,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: radius(jcbButtonRadius)),
                          elevation: 0,
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(searchResults[index]),
                              onTap: () async {
                                destination.text = searchResults[index];
                                searchResults.clear();
                                setState(() {});
                                LatLng? selectedLatLng =
                                    await reverseGeocodeAddress(
                                        destination.text);

                                if (selectedLatLng != null) {
                                  toast('Location added!');
                                } else {
                                  toast('invalid destination');
                                }
                              },
                            );
                          }),
                    ],
                  ).expand(),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: appStore.isDarkModeOn
                            ? context.dividerColor
                            : jcbSecBorderColor)),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: radius(100),
                          color: jcbGreyColor.withOpacity(0.2),
                        ),
                        child: IconButton(
                          icon: Image.asset(
                            'images/juberCarBooking/jcbIcons/ic_home.png',
                            color: jcbGreyColor,
                            height: 20,
                            width: 20,
                            fit: BoxFit.cover,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      16.width,
                      Text('Home', style: primaryTextStyle())
                    ],
                  ),
                  Divider(indent: 60, thickness: 1),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: radius(100),
                          color: jcbGreyColor.withOpacity(0.2),
                        ),
                        child: IconButton(
                            icon: Image.asset(
                              'images/juberCarBooking/jcbIcons/ic_suitcase.png',
                              color: jcbGreyColor,
                              height: 22,
                              width: 22,
                            ),
                            onPressed: () {
                              JCBFavouriteScreen().launch(context);
                            }),
                      ),
                      16.width,
                      Text('Work', style: primaryTextStyle())
                    ],
                  ),
                ],
              ),
            ).onTap(() {
              JCBFavouriteScreen().launch(context);
            },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent),
            Divider(
                thickness: 10,
                height: 10,
                color: appStore.isDarkModeOn
                    ? context.cardColor
                    : jcbBackGroundColor),
          ],
        ),
      ),
    );
  }
}
