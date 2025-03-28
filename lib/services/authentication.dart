import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireBaseAuthentication {
  static Future<String> signUpWithEmail(String email, String password,
      String firstName, String lastName, String phone, String type) async {
    try {
      String generateUserId() {
        final uuid = Uuid();
        String generatedUserId = uuid.v4();
        return generatedUserId.substring(0, 6);
      }

      String userId = generateUserId();

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': userId,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
          'type': type,
          'createdAte': FieldValue.serverTimestamp(),
        });
        return "Account Created";
      }
      return 'Failed to create Account!';
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> driverSignUp(String email, String password,
      String firstName, String lastName, String phone, String type) async {
    try {
      String generateDriverId() {
        final uuid = Uuid();
        String generatedUserId = uuid.v4();
        return generatedUserId.substring(0, 6);
      }

      String driverId = generateDriverId();

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'driverId': driverId,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
          'type': type,
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
        });
        return "Account Created";
      }
      return 'Error Creating Account';
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login Success!";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  static Future logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  static Future<bool> isUserLoggedIn() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null ? true : false;
  }
}
