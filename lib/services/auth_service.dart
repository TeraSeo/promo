import 'package:firebase_auth/firebase_auth.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/services/userService.dart';

class AuthServie {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future loginWithUserNameandPassword(String email, String password) async {

    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword (
        email: email, password: password
      )).user!;

      if (user != null) {
         return true;
      }

    } on FirebaseAuthException catch(e) {
      return e.message; 
    }

  }
    

  // register
  Future registerUserWithEmailandPassword(String name, String email, String password) async {

    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password
      )).user!;

      if (user != null) {
        await DatabaseService(uid: user.uid).savingeUserData(name, email);

        return true;
      }

    } on FirebaseAuthException catch(e) {
      return e.message; 
    }

  }

  // signOut
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
    } catch (e) {
      return null;
    }
  }

}