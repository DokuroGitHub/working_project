import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:working_project/models/my_user.dart';
import 'package:working_project/services/database_service.dart';

class AuthService {
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }

  Future<UserCredential> Function() signInAnonymously() {
    return FirebaseAuth.instance.signInAnonymously;
  }

  Future<UserCredential> signInWithCredential(String email, String password) {
    return FirebaseAuth.instance.signInWithCredential(
        EmailAuthProvider.credential(email: email, password: password));
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<User?> signInWithGoogle() async {
    print('ok0');
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      //TODO: clientId: neu co trong index.html thi ko can
      //clientId: '206090578730-u0v0gren2a0gmvi8obamjvfj5v1n16u6.apps.googleusercontent.com',
      clientId:
          '742561613196-t79nbi76lo4eiji1umr1rtkalsdtf5pb.apps.googleusercontent.com',
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );

    print('ok2');
    print(_googleSignIn.currentUser);
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    print('ok3');

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    print('googleSignInAccount!.authentication: ${googleSignInAuthentication.accessToken}');
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    //TODO: try signInMethods, not done
    List<String> signInMethods = await FirebaseAuth.instance
        .fetchSignInMethodsForEmail(googleSignInAccount.email);
    print('signInMethods: $signInMethods');

    UserCredential result =
        await FirebaseAuth.instance.signInWithCredential(credential);

    User? userDetails = result.user;
    return userDetails;
  }

  Future<MyUser?> _signInWithGoogle() async {
    User? authUser = await signInWithGoogle();
    if (authUser == null) {
      print('authUser null');
      return null;
    } else {
      String uid = authUser.uid;
      print('uid: $uid');
      MyUser? myUser = await DatabaseService().getMyUserByDocumentId(uid);
      if (myUser == null) {
        print('myUser null, add vao db');
        //TODO: new
        MyUser x = MyUser(
          address: null,
          birthDate: null,
          createdAt: DateTime.now(),
          email: authUser.email,
          isActive: true,
          isBlocked: false,
          lastSignInAt: DateTime.now(),
          name: authUser.displayName,
          phoneNumber: authUser.phoneNumber,
          photoURL: authUser.photoURL,
          role: 'MEMBER',
          selfIntroduction: null,
          shipperInfo: null,
        );
        //TODO: add
        DatabaseService().addMyUserToDBWithId(uid, x.toMap());
        return DatabaseService().getMyUserByDocumentId(uid);
      } else {
        //TODO: co r khoi add
        print('co r khoi add, myUser: $myUser');
        return myUser;
      }
    }
  }

}
