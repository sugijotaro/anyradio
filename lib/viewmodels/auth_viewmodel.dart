import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/user.dart' as custom_user;

class AuthViewModel extends ChangeNotifier {
  static final AuthViewModel _instance = AuthViewModel._internal();
  factory AuthViewModel() => _instance;
  AuthViewModel._internal() {
    authenticateUser();
  }

  bool userExists = false;
  bool isFetchingUser = true;
  custom_user.User? currentUser;
  String alertMessage = "";

  void authenticateUser() {
    if (FirebaseAuth.instance.currentUser == null) {
      FirebaseAuth.instance.signInAnonymously().then((authResult) {
        if (authResult.user != null) {
          checkUserExists(authResult.user!.uid);
        } else {
          alertMessage = "Authentication failed: Could not retrieve user data.";
          notifyListeners();
        }
      }).catchError((error) {
        alertMessage = "Login Error: ${error.message}";
        notifyListeners();
      });
    } else {
      checkUserExists(FirebaseAuth.instance.currentUser!.uid);
    }
  }

  void checkUserExists(String userId) {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    docRef.get().then((document) {
      if (document.exists) {
        currentUser = custom_user.User.fromDocument(document);
        userExists = true;
        isFetchingUser = false;
        notifyListeners();
      } else {
        userExists = false;
        isFetchingUser = false;
        notifyListeners();
      }
    }).catchError((error) {
      alertMessage = "Error checking user: ${error.message}";
      notifyListeners();
    });
  }

  void createNewUser() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final newUser = custom_user.User(
      id: userId,
      username: 'New User',
      profileImageUrl: '',
      likedRadios: [],
    );

    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    docRef.set(newUser.toMap()).then((_) {
      currentUser = newUser;
      userExists = true;
      isFetchingUser = false;
      FirebaseAnalytics.instance
          .logEvent(name: 'new_user_created', parameters: {'user_id': userId});
      notifyListeners();
    }).catchError((error) {
      alertMessage = "User Creation Error: ${error.message}";
      notifyListeners();
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut().then((_) {
      userExists = false;
      currentUser = null;
      alertMessage = "";
      notifyListeners();
    }).catchError((error) {
      alertMessage = "Sign out error: ${error.message}";
      notifyListeners();
    });
  }

  void fetchCurrentUser() {
    isFetchingUser = true;
    notifyListeners();

    if (currentUser == null) {
      alertMessage = "Unable to obtain user ID.";
      isFetchingUser = false;
      notifyListeners();
      return;
    }

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.id);
    docRef.get().then((document) {
      if (document.exists) {
        currentUser = custom_user.User.fromDocument(document);
      } else {
        alertMessage = "User not found.";
      }
      isFetchingUser = false;
      notifyListeners();
    }).catchError((error) {
      alertMessage = "User Retrieval Error: ${error.message}";
      isFetchingUser = false;
      notifyListeners();
    });
  }
}
