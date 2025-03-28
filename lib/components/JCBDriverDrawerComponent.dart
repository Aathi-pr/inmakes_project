import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juber_car_booking/main.dart';
import 'package:juber_car_booking/screens/JCBUpdateInfoScreen.dart';
import 'package:juber_car_booking/services/authentication.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:juber_car_booking/screens/JCBFavouriteScreen.dart';
import 'package:juber_car_booking/screens/JCBMyRidesScreen.dart';
import 'package:juber_car_booking/screens/JCBPaymentMethodScreen.dart';
import 'package:juber_car_booking/screens/JCBPromotionsScreen.dart';
import 'package:juber_car_booking/utils/JBCColors.dart';

class JCBDriverDrawerComponent extends StatefulWidget {
  const JCBDriverDrawerComponent({Key? key}) : super(key: key);

  @override
  State<JCBDriverDrawerComponent> createState() =>
      _JCBDriverDrawerComponentState();
}

class _JCBDriverDrawerComponentState extends State<JCBDriverDrawerComponent> {
  String userName = 'Loading..';
  String phoneNumber = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userData.exists) {
      setState(() {
        userName = userData['firstName'];

        phoneNumber = userData['phone'] ?? '';
        imageUrl = userData['profileImage'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: jcbPrimaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Image.network(
                    imageUrl,
                    height: 58,
                    width: 58,
                    fit: BoxFit.cover,
                  ).cornerRadiusWithClipRRect(100),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: radius(100),
                  ),
                ),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(userName,
                            style:
                                boldTextStyle(color: Colors.white, size: 18)),
                        Text(phoneNumber,
                            style:
                                secondaryTextStyle(color: jcbSecBorderColor)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 16),
                      onPressed: () {
                        finish(context);
                        JCBUpdaeScreenInfo().launch(context);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            minLeadingWidth: 0,
            title: Text("Recent rides", style: boldTextStyle()),
            leading: Icon(Icons.access_time_rounded, color: jcbGreyColor),
            onTap: () {
              finish(context);
              JCBMyRidesScreen().launch(context);
            },
          ),
          ListTile(
            minLeadingWidth: 0,
            title: Text("Dark Mode", style: boldTextStyle()),
            leading: Image.asset(
              'images/juberCarBooking/jcbIcons/ic_theme.png',
              color: jcbGreyColor,
              height: 20,
              width: 20,
              fit: BoxFit.cover,
            ),
            trailing: Switch(
              value: appStore.isDarkModeOn,
              onChanged: (bool value) {
                appStore.toggleDarkMode(value: value);
                setState(() {});
              },
            ),
            onTap: () {},
          ),
          ListTile(
            minLeadingWidth: 0,
            title: Text("Log out", style: boldTextStyle()),
            leading: Icon(
              Icons.logout,
              color: Colors.grey,
            ),
            onTap: () async {
              await FireBaseAuthentication.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
