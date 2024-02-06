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

      DatabaseService databaseService = DatabaseService.instance;

      if (user != null) {
        await databaseService.savingeUserData(name, email, user.uid);

        return true;
      }

    } on FirebaseAuthException catch(e) {
      return e.message; 
    }

  }

  // signOut
  Future signOut() async {
    try {
      HelperFunctions helperFunctions = HelperFunctions();
      
      await firebaseAuth.signOut();
      await helperFunctions.saveUserLoggedInStatus(false);
      await helperFunctions.saveUserEmailSF("");
      await helperFunctions.saveUserNameSF("");
    } catch (e) {
      return null;
    }
  }

}