import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:juber_car_booking/components/JCBFormTextField.dart';
import 'package:juber_car_booking/utils/JBCColors.dart';
import 'package:juber_car_booking/utils/JCBConstants.dart';
import 'package:juber_car_booking/main.dart';

class JCBProfileScreen extends StatefulWidget {
  @override
  State<JCBProfileScreen> createState() => _JCBProfileScreenState();
}

class _JCBProfileScreenState extends State<JCBProfileScreen> {
  bool isPref = true;
  String name = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userData.exists) {
      name = userData['firstName'];
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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: boldTextStyle(
                      size: 40,
                      fontFamily: jcbFont,
                      color:
                          appStore.isDarkModeOn ? Colors.white : jcbDarkColor,
                      weight: FontWeight.w900),
                ),
                Image.asset(
                  'images/juberCarBooking/jcb_face2.jpg',
                  height: 58,
                  width: 58,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRect(100)
              ],
            ),
            20.height,
            JCBFormTextField(
              label: 'Name'.toUpperCase(),
              textFieldType: TextFieldType.NAME,
            ),
            16.height,
            JCBFormTextField(
              keyboardType: TextInputType.emailAddress,
              label: 'Email'.toUpperCase(),
              textFieldType: TextFieldType.EMAIL,
            ),
            16.height,
            JCBFormTextField(
              label: 'Phone Number'.toUpperCase(),
              textFieldType: TextFieldType.PHONE,
              keyboardType: TextInputType.number,
            ),
            16.height,
            JCBFormTextField(
              textInputAction: TextInputAction.done,
              label: 'Password'.toUpperCase(),
              textFieldType: TextFieldType.PASSWORD,
            ),
            16.height,
            AppButton(
              width: context.width() -32,
              child: Text('Update'.toUpperCase(),
                style: boldTextStyle(color: Colors.white),
              ),
              onTap: (){},
              color: jcbPrimaryColor,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: radius(jcbButtonRadius)
              ),
            ),
            16.height,
            Text('Preferences'.toUpperCase(),
                style: boldTextStyle(color: jcbGreyColor, size: 14)),
            6.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(color: jcbSecBorderColor),
                  borderRadius: radius(jcbButtonRadius)),
              width: context.width() - 32,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('receive receipt emails'.toUpperCase(),
                          style: boldTextStyle(
                              color: appStore.isDarkModeOn
                                  ? Colors.white
                                  : jcbDarkColor)),
                      Container(
                        width: 60,
                        decoration: BoxDecoration(
                            color: isPref ? jcbPrimaryColor : jcbGreyColor,
                            borderRadius: radius(50)),
                        child: Align(
                          alignment:
                              isPref ? Alignment.topRight : Alignment.topLeft,
                          child: Icon(
                              isPref ? Icons.check_circle : Icons.circle,
                              color: Colors.white,
                              size: 30),
                        ),
                      ).onTap(
                        () {
                          isPref = !isPref;
                          setState(() {});
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  16.height,
                  Text(
                    'Stay up to date with our new and cool promos and receive a more personalized experience.',
                    style: secondaryTextStyle(color: jcbGreyColor),
                  ),
                ],
              ),
            ),
            16.height,
            Text('Social Network'.toUpperCase(),
                style: boldTextStyle(color: jcbGreyColor, size: 14)),
            16.height,
            AppButton(
              padding: EdgeInsets.symmetric(horizontal: 4),
              width: context.width() - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('images/juberCarBooking/fb_logo.png',
                      height: 50, width: 50, fit: BoxFit.cover),
                  Text('Connect with Facebook',
                      style: boldTextStyle(color: Colors.white)),
                  SizedBox(width: 5),
                ],
              ),
              onTap: () {},
              color: Color(0xFF4267B2),
              shapeBorder:
                  RoundedRectangleBorder(borderRadius: radius(jcbButtonRadius)),
              elevation: 0,
            ),
            16.height,
            AppButton(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              width: context.width() - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('images/juberCarBooking/jcbIcons/ic_google.png',
                      height: 30, width: 30, fit: BoxFit.cover),
                  Text('Connect with Google',
                      style: boldTextStyle(
                          color: appStore.isDarkModeOn
                              ? Colors.white
                              : jcbDarkColor)),
                  SizedBox(width: 5),
                ],
              ),
              onTap: () {},
              color: context.scaffoldBackgroundColor,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: radius(jcbButtonRadius),
                side: BorderSide(color: jcbSecBorderColor),
              ),
              elevation: 0,
            ),
            30.height,
          ],
        ),
      ),
    );
  }
}
