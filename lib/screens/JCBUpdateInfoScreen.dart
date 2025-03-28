import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:juber_car_booking/components/JCBFormTextField.dart';
import 'package:juber_car_booking/utils/JBCColors.dart';
import 'package:juber_car_booking/utils/JCBCommon.dart';
import 'package:juber_car_booking/utils/JCBConstants.dart';
import 'package:juber_car_booking/main.dart';

// ignore: must_be_immutable

class JCBUpdaeScreenInfo extends StatefulWidget {
  @override
  State<JCBUpdaeScreenInfo> createState() => _JCBUpdaeScreenInfoState();
}

class _JCBUpdaeScreenInfoState extends State<JCBUpdaeScreenInfo> {
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode firstName = FocusNode();
  FocusNode lastName = FocusNode();
  FocusNode email = FocusNode();
  FocusNode password = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    profileImage();
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userData.exists) {
      setState(() {
        firstNameCont.text = userData['firstName'] ?? '';
        lastNameCont.text = userData['lastName'] ?? '';
        emailCont.text = userData['email'] ?? '';
        imageUrl = userData['profileImage'] ?? '';
      });
    }
  }

  Future<void> updateUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    String newPassword = passwordCont.text;

    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstName': firstNameCont.text,
        'lastName': lastNameCont.text,
        'email': emailCont.text,
      });

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }
      toast('Profile Upated Succesfuly');
    } catch (e) {
      toast('Error Updating Profile : ${e.toString()}');
    }
  }

  String? imageUrl;
  File? _image;

  Future<void> profileImage() async {
    final newImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (newImage == null) return;

    File file = File(newImage.path);
    String userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      _image = file;
    });

    Reference ref =
        FirebaseStorage.instance.ref().child('profile_pic/$userId.jpg');
    await ref.putFile(file);
    String downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profileImage': downloadUrl,
    });

    setState(() {
      imageUrl = "$downloadUrl?t=${DateTime.now().millisecondsSinceEpoch}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: jcbBackWidget(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update \ninformation',
                style: boldTextStyle(
                    size: 40,
                    fontFamily: jcbFont,
                    color: appStore.isDarkModeOn ? Colors.white : jcbDarkColor,
                    weight: FontWeight.w900)),
            20.height,
            GestureDetector(
              onTap: profileImage,
              child: CircleAvatar(
                radius: 100,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (imageUrl != null && imageUrl!.isNotEmpty)
                        ? NetworkImage(imageUrl!)
                        : AssetImage('images/juberCarBooking/jcb_face2.jpg')
                            as ImageProvider,
                child: Icon(
                  Icons.camera_alt,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
            20.height,
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
              nextFocus: password,
              label: 'Email',
              textFieldType: TextFieldType.EMAIL,
            ),
            16.height,
            JCBFormTextField(
              controller: passwordCont,
              focus: password,
              textInputAction: TextInputAction.done,
              label: 'Password',
              textFieldType: TextFieldType.PASSWORD,
            ),
            80.height,
            AppButton(
              width: context.width() - 32,
              child: Text('Save information'.toUpperCase(),
                  style: boldTextStyle(color: Colors.white)),
              onTap: () {
                updateUserDetails();
                // JCBGetStartedScreen().launch(context);
              },
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
