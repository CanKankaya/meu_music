import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

UserCredential? currentUser;

Future<String?> register(
  String email,
  String password,
  String name,
  String surname,
  String phonenumber,
  String studentId,
) async {
  try {
    var userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    log(currentUser?.user?.uid ?? "No UID");

    return userCredential.user?.uid;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'The user corresponding to the given email has been disabled.';
      default:
        return 'Unhandled exception: ${e.code}';
    }
  } catch (e) {
    return e.toString();
  }
}

Future<String?> login(String email, String password) async {
  try {
    currentUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    log(currentUser?.user?.uid ?? "No UID");
    return null;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      default:
        return 'Unhandled exception: ${e.code}';
    }
  }
}

Future<String> logout() async {
  try {
    await FirebaseAuth.instance.signOut();
    return "Logout successful!";
  } catch (e) {
    return e.toString();
  }
}

//add a data to firestore in users collection
Future<String> addUserDataToFirestore(
  String name,
  String surname,
  String phonenumber,
  String studentId,
) async {
  try {
    await FirebaseFirestore.instance.collection("users").add({
      "name": name,
      "surname": surname,
      "phonenumber": phonenumber,
      "studentId": studentId,
      "createdDateTime": DateTime.now(),
    });
    return "Data added to Firestore!";
  } catch (e) {
    return e.toString();
  }
}

Future<String> deleteUserDataFromFirestore(String uid) async {
  try {
    await FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: uid)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
    return "User data deleted from Firestore!";
  } catch (e) {
    return e.toString();
  }
}
