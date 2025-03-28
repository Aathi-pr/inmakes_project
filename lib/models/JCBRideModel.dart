import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class JCBRideModel {
  String title;
  String? name;
  String? phone;
  String? email;
  String subTitle;
  String cost;
  String time;
  bool? isBest;
  String image;

  JCBRideModel(
      {required this.title,
      this.name,
      this.phone,
      this.email,
      required this.subTitle,
      required this.cost,
      required this.time,
      this.isBest,
      required this.image});

  static Future _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemark = await placemarkFromCoordinates(lat, lng);
      if (placemark.isNotEmpty) {
        Placemark place = placemark.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  static Future<JCBRideModel> fromJson(
      String id, Map<String, dynamic> json) async {
    Map<String, dynamic>? destinationLocation =
        json['destinationLocation'] as Map<String, dynamic>?;

    Map<String, dynamic>? currentLocation =
        json['currentLocation'] as Map<String, dynamic>?;

    String pickup = 'Unknown Location';
    String dropoff = "Unknown Destination";

    if (currentLocation != null) {
      double lat = currentLocation['latitude'];
      double lng = currentLocation['logitude'];
      pickup = await _getAddressFromLatLng(lat, lng);
    }

        if (destinationLocation != null) {
      double lat = destinationLocation['latitude'];
      double lng = destinationLocation['logitude'];
      dropoff = await _getAddressFromLatLng(lat, lng);
    }

    String userName = json['userName'] ?? 'Unknown User';
    String phoneNumber = json['userPhone'] ?? 'Phone';
    String email = json['email'] ?? 'Email';

    Timestamp? requestTimestamp = json['requestDate'] as Timestamp?;
    String formattedTime = requestTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(
                requestTimestamp.millisecondsSinceEpoch)
            .toString()
        : "Unknown Time";

    return JCBRideModel(
      title: json['requestID'] ?? 'Unknown Ride',
      name: userName,
      email: email,
      phone: phoneNumber,
      subTitle: "$pickup -> \n$dropoff",
      cost: '\$25.00',
      time: formattedTime,
      isBest: false,
      image: 'images/juberCarBooking/jcb_map.png',
    );
  }
}

List<JCBRideModel> getRideTypes() {
  List<JCBRideModel> list = [];

  list.add(JCBRideModel(
    title: 'JuberGo',
    image: 'images/juberCarBooking/juberRides/juber_go.png',
    cost: '\$25.50',
    isBest: true,
    subTitle: 'Best Save',
    time: '1-4 min',
  ));
  list.add(JCBRideModel(
    title: 'Jubercar',
    image: 'images/juberCarBooking/juberRides/juber_car.png',
    cost: '\$35.00',
    isBest: false,
    subTitle: '4 seats',
    time: '1-5 min',
  ));
  list.add(JCBRideModel(
    title: 'Juberbike',
    image: 'images/juberCarBooking/juberRides/juber_bike.png',
    cost: '\$10.00',
    isBest: false,
    subTitle: 'Pay Less',
    time: '1-5 min',
  ));
  list.add(JCBRideModel(
    title: 'Jubercar7',
    image: 'images/juberCarBooking/juberRides/juber_car7.png',
    cost: '\$65.00',
    isBest: false,
    subTitle: '7 seats',
    time: '1-5 min',
  ));
  list.add(JCBRideModel(
    title: 'Jubercar4',
    image: 'images/juberCarBooking/juberRides/juber_car4.png',
    cost: '\$45.00',
    isBest: false,
    subTitle: '4 seats',
    time: '1-5 min',
  ));
  list.add(JCBRideModel(
    title: 'Jubertaxi',
    image: 'images/juberCarBooking/juberRides/juber_taxi.png',
    cost: '\$40.00',
    isBest: false,
    subTitle: '4 seats',
    time: '1-5 min',
  ));

  return list;
}

Future<List<JCBRideModel>> getMyRides() async {
  List<JCBRideModel> list = [];

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('rideRequests')
      .where('status', isEqualTo: 'Accepted')
      .get();

  for (var doc in snapshot.docs) {
    var ride =
        await JCBRideModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    list.add(ride);
  }

  return list;
}
