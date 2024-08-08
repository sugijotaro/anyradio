import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AuthViewModel extends ChangeNotifier {
  static final AuthViewModel _instance = AuthViewModel._internal();
  factory AuthViewModel() => _instance;
  AuthViewModel._internal() {
    authenticateAndCreateUser();
  }

  bool isAuthenticated = false;
  bool isFetchingUser = true;
  User? currentUser;
  String alertMessage = "";

  void authenticateAndCreateUser() {
    if (FirebaseAuth.instance.currentUser == null) {
      FirebaseAuth.instance.signInAnonymously().then((authResult) {
        if (authResult.user != null) {
          currentUser = authResult.user;
          createNewUserIfNeeded(currentUser!.uid);
        } else {
          alertMessage = "Authentication failed: Could not retrieve user data.";
          notifyListeners();
        }
      }).catchError((error) {
        alertMessage = "Login Error: ${error.message}";
        notifyListeners();
      });
    } else {
      isAuthenticated = true;
      fetchCurrentUser();
    }
  }

  void createNewUserIfNeeded(String userId) {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    docRef.get().then((document) {
      if (document.exists) {
        fetchCurrentUser();
      } else {
        final newUser = {'id': userId, 'nickname': 'New User'};
        docRef.set(newUser).then((_) {
          currentUser = FirebaseAuth.instance.currentUser;
          FirebaseAnalytics.instance.logEvent(
              name: 'new_user_created', parameters: {'user_id': userId});
          notifyListeners();
        }).catchError((error) {
          alertMessage = "User Creation Error: ${error.message}";
          notifyListeners();
        });
      }
    }).catchError((error) {
      alertMessage = "Error fetching user: ${error.message}";
      notifyListeners();
    });
  }

  void signOut() {
    FirebaseAuth.instance.signOut().then((_) {
      isAuthenticated = false;
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
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    docRef.get().then((document) {
      if (document.exists) {
        currentUser = FirebaseAuth.instance.currentUser;
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
