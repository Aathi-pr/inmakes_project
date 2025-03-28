import 'package:flutter/material.dart';
import 'package:juber_car_booking/screens/driver_screens/JCBDriverHomeScreen.dart';
import 'package:juber_car_booking/services/authentication.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:juber_car_booking/components/JCBFormTextField.dart';
import 'package:juber_car_booking/screens/JCBLoginScreen.dart';
import 'package:juber_car_booking/screens/JCBSelectCountryCodeScreen.dart';
import 'package:juber_car_booking/utils/JBCColors.dart';
import 'package:juber_car_booking/utils/JCBCommon.dart';
import 'package:juber_car_booking/utils/JCBConstants.dart';
import 'package:juber_car_booking/main.dart';

class JCBDriverSignUpScreen extends StatefulWidget {
  @override
  State<JCBDriverSignUpScreen> createState() => _JCBDriverSignUpScreenState();
}

class _JCBDriverSignUpScreenState extends State<JCBDriverSignUpScreen> {
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController phoneNoCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode firstName = FocusNode();
  FocusNode lastName = FocusNode();
  FocusNode email = FocusNode();
  FocusNode phoneNo = FocusNode();
  FocusNode password = FocusNode();

  String countryCode = '+1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: jcbBackWidget(context),
        actions: [
          Text(
            'Log in',
            style: boldTextStyle(color: jcbPrimaryColor),
          ).center().paddingSymmetric(horizontal: 16).onTap(() {
            finish(context);
            JCBLoginScreen().launch(context);
          },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign up',
              style: boldTextStyle(
                size: 40,
                fontFamily: jcbFont,
                color: appStore.isDarkModeOn ? Colors.white : jcbDarkColor,
                weight: FontWeight.w900,
              ),
            ),
            30.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                JCBFormTextField(
                  controller: firstNameCont,
                  focus: firstName,
                  nextFocus: lastName,
                  autoFocus: false,
                  label: 'First Name',
                  width: context.width() / 2 - 24,
                  textFieldType: TextFieldType.NAME,
                  labelSpace: true,
                ),
                JCBFormTextField(
                  controller: lastNameCont,
                  focus: lastName,
                  nextFocus: email,
                  label: 'Last Name',
                  width: context.width() / 2 - 24,
                  textFieldType: TextFieldType.NAME,
                  labelSpace: true,
                ),
              ],
            ),
            16.height,
            JCBFormTextField(
              keyboardType: TextInputType.emailAddress,
              controller: emailCont,
              focus: email,
              nextFocus: phoneNo,
              label: 'Email',
              textFieldType: TextFieldType.EMAIL,
            ),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Country Code',
                        style: boldTextStyle(color: jcbGreyColor, size: 14)),
                    6.height,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: appStore.isDarkModeOn
                                  ? context.dividerColor
                                  : jcbSecBorderColor),
                          borderRadius: radius(jcbButtonRadius)),
                      width: context.width() * 0.26,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(countryCode, style: boldTextStyle()),
                          Icon(Icons.keyboard_arrow_down_outlined),
                        ],
                      ),
                    ).onTap(() {
                      JCBSelectCountryCodeScreen()
                          .launch(context)
                          .then((value) {
                        countryCode = value;
                        setState(() {});
                      });
                    })
                  ],
                ),
                JCBFormTextField(
                  controller: phoneNoCont,
                  focus: phoneNo,
                  nextFocus: password,
                  label: 'Phone Number',
                  width: context.width() * 0.6,
                  textFieldType: TextFieldType.PHONE,
                  labelSpace: true,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            16.height,
            JCBFormTextField(
              controller: passwordCont,
              focus: password,
              textInputAction: TextInputAction.done,
              label: 'Password',
              textFieldType: TextFieldType.PASSWORD,
            ),
            20.height,
            RichText(
              text: TextSpan(
                text: 'By clicking "Sign Up" you agree to our ',
                style: secondaryTextStyle(color: context.iconColor),
                children: <TextSpan>[
                  TextSpan(
                      text: 'terms and conditions',
                      style: secondaryTextStyle(
                          color: context.iconColor,
                          decoration: TextDecoration.underline)),
                  TextSpan(
                      text: ' as well as our ',
                      style: secondaryTextStyle(color: context.iconColor)),
                  TextSpan(
                      text: 'privacy policy',
                      style: secondaryTextStyle(
                          color: context.iconColor,
                          decoration: TextDecoration.underline)),
                ],
              ),
            ),
            80.height,
            AppButton(
              width: context.width() - 32,
              child: Text('Sign Up As Driver'.toUpperCase(),
                  style: boldTextStyle(color: Colors.white)),
              onTap: (() async {
                String message = await FireBaseAuthentication.driverSignUp(
                    emailCont.text,
                    passwordCont.text,
                    firstNameCont.text,
                    lastNameCont.text,
                    phoneNoCont.text,
                    'Driver');

                toast(message);
                if (message == 'Account Created') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => JCBDriverHomeScreen()));
                }
              }),
              color: jcbPrimaryColor,
              shapeBorder:
                  RoundedRectangleBorder(borderRadius: radius(jcbButtonRadius)),
              elevation: 0,
            ),
          ],
        ),
      ),
    );
  }
}
