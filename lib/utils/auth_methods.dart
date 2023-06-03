import 'dart:typed_data';
import 'package:brainfood/models/user_model.dart';
import 'package:brainfood/utils/firebase_storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:username_gen/username_gen.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get logged in user details
  Future<MyUser> getUserDetails() async {
    MyUser user = MyUser(
        email: "",
        uid: "",
        photoUrl:
            "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
        username: "SleepingBeauty",
        friends: [],
        lastActive: Timestamp.now(),
        starred: []);
    User currentUser = _auth.currentUser!;
    bool isAnonymous = currentUser.isAnonymous;
    if (isAnonymous) {
      return user;
    } else {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(currentUser.uid).get();
      return MyUser.fromSnap(snap);
    }
  }

  // Future<String> getSpecificUserDetail(String uid) async {
  //   DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
  //   String username = snap['username'];
  //   return username;
  // }

  Future<String> editProfile({
    required String uid,
    required String username,
    Uint8List? file,
  }) async {
    String res = "Some error occured";
    try {
      List<Uint8List> files = [];
      String photoUrl;
      if (username.isEmpty && file == null) {
        //no changes
      } else if (username.isNotEmpty && file == null) {
        await _firestore
            .collection("users")
            .doc(uid)
            .update({'username': username});
      } else if (username.isEmpty && file != null) {
        files.add(file);
        List<String> list = await StorageMethods()
            .uploadImageToStorage('profilePics', files, false);
        photoUrl = list[1];
        await _firestore.collection("users").doc(uid).update({
          'photoUrl': photoUrl,
        });
      } else if (username.isNotEmpty && file != null) {
        files.add(file);
        List<String> list = await StorageMethods()
            .uploadImageToStorage('profilePics', files, false);
        photoUrl = list[1];
        await _firestore.collection("users").doc(uid).update({
          'username': username,
          'photoUrl': photoUrl,
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //set active status
  Future<void> setStatus() async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore
          .collection("users")
          .doc(uid)
          .update({'lastActive': FieldValue.serverTimestamp()});
    } catch (err) {
      //err
    }
  }

  //signing up user
  Future<String> signUpUser({
    String email = '',
    String password = '',
    String confirmpass = '',
    String username = '',
    bool secondScreen = false,
    Uint8List? file,
  }) async {
    String res = "Some error occured";
    try {
      String photoUrl;
      if (!secondScreen) {
        if (email.isEmpty) {
          res = "Email is empty";
        } else if (password.isEmpty) {
          res = "Password is empty";
        } else if (confirmpass.isEmpty) {
          res = "Confirm password cannot be empty";
        } else if (confirmpass != password) {
          res = "Passwords do not match";
        } else {
          //create user
          UserCredential cred = await _auth.createUserWithEmailAndPassword(
              email: email, password: password);
          //create random username
          String randomUsername = UsernameGen.generateWith();
          //add user to firestore
          MyUser user = MyUser(
              email: "",
              uid: "",
              photoUrl:
                  "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
              username: "SleepingBeauty",
              friends: [],
              lastActive: Timestamp.now(),
              starred: []);
          await _firestore.collection("users").doc(cred.user!.uid).set(
                user.toJson(),
              );
          res = "success";
        }
      } else {
        if (username.isEmpty) {
          res = 'Username is empty';
          return res;
        }
        //get photourl
        if (file != null) {
          List<Uint8List> files = [];
          files.add(file);
          List<String> list = await StorageMethods()
              .uploadImageToStorage('profilePics', files, false);
          photoUrl = list[1];
        } else {
          photoUrl =
              'https://t3.ftcdn.net/jpg/00/64/67/80/240_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg';
        }

        //add user to firestore
        MyUser user = MyUser(
            email: "",
            uid: "",
            photoUrl:
                "https://t4.ftcdn.net/jpg/02/15/84/43/240_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg",
            username: "SleepingBeauty",
            friends: [],
            lastActive: Timestamp.now(),
            starred: []);

        await _firestore.collection("users").doc(_auth.currentUser!.uid).set(
              user.toJson(),
            );
        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted';
      } else if (err.code == 'weak-password') {
        res = 'Password should be at least 6 characters';
      } else if (err.code == 'email-already-in-use') {
        res = 'The email address is already in use by another account';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> sendPassResetLink({
    required String email,
  }) async {
    String res = "Some error occurred";
    try {
      await _auth.sendPasswordResetEmail(email: email);
      res = "success";
    } on FirebaseAuthException catch (err) {
      //firebase error
      res = err.message.toString();
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //loggin in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isEmpty) {
        res = "Email is empty";
      } else if (password.isEmpty) {
        res = "Password is empty";
      } else {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'wrong-password') {
        res = 'Email or password is incorrect';
      } else if (err.code == 'user-not-found') {
        res = 'Mail or password is incorrect';
      } else if (err.code == 'invalid-email') {
        res = 'Bad email formatting';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //sign in anonymous
  Future<String> signInAnonymously() async {
    String res = "Some error occured";
    try {
      await _auth.signInAnonymously();
      res = "success";
    } on FirebaseAuthException catch (err) {
      if (err.code == 'network-request-failed') {
        res = 'Check your network connection';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  //signing out user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
