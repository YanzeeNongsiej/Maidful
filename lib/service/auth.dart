import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:ibitf_app/home.dart';

class AuthMethods {
  // final FirebaseAuth auth = FirebaseAuth.instance;

  var verificationId = ''.obs;
  String smscode = "";
  TextEditingController codeController = TextEditingController();
  static User? user = FirebaseAuth.instance.currentUser;

  static Future<User?> loginWithGoogle() async {
    final googleAccount = await GoogleSignIn().signIn();

    final googleAuth = await googleAccount?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final UserCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return UserCredential.user;
  }

  Future<void> phoneAuthentication(String phoneNo, BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${phoneNo.trim()}',
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home()));
        });
      },
      codeSent: (verificationId, resendToken) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Enter OTP"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: codeController,
                      )
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          smscode = codeController.text;
                          PhoneAuthCredential credentials =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: smscode);
                          FirebaseAuth.instance
                              .signInWithCredential(credentials)
                              .then((result) {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home()));
                          });
                        },
                        child: Text("Done"))
                  ],
                ));
        this.verificationId.value = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) {
        this.verificationId.value = verificationId;
      },
      timeout: Duration(seconds: 3),
      verificationFailed: (e) {
        print("Error code:${e.code}; Message:${e.message}");
        if (e.code == 'invalid-phone-number') {
          Get.snackbar('Error', 'The provided Phone Number is not valid.');
        } else {
          Get.snackbar('Error', 'Something wemt worng, Try again');
        }
      },
    );
  }

  Future<bool> verifyOTP(String otp) async {
    var credentials = await FirebaseAuth.instance.signInWithCredential(
        PhoneAuthProvider.credential(
            verificationId: verificationId.value, smsCode: otp));
    return credentials.user != null ? true : false;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  // getCurrentUser() async {
  //   return await auth.currentUser;
  // }

  // signInWithGoogle(BuildContext context) async {
  //   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   final GoogleSignIn googleSignIn = GoogleSignIn();

  //   final GoogleSignInAccount? googleSignInAccount =
  //       await googleSignIn.signIn();

  //   final GoogleSignInAuthentication? googleSignInAuthentication =
  //       await googleSignInAccount?.authentication;

  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //       idToken: googleSignInAuthentication?.idToken,
  //       accessToken: googleSignInAuthentication?.accessToken);

  //   UserCredential result = await firebaseAuth.signInWithCredential(credential);

  //   User? userDetails = result.user;

  //   if (userDetails != null) {
  //     Map<String, dynamic> userInfoMap = {
  //       "email": userDetails!.email,
  //       "name": userDetails.displayName,
  //       "imgUrl": userDetails.photoURL,
  //       "id": userDetails.uid
  //     };
  //     await DatabaseMethods()
  //         .addUser(userDetails.uid, userInfoMap)
  //         .then((value) {
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => Home()));
  //     });
  //   }
  // }

  // Future<User> signInWithApple({List<Scope> scopes = const []}) async {
  //   final result = await TheAppleSignIn.performRequests(
  //       [AppleIdRequest(requestedScopes: scopes)]);
  //   switch (result.status) {
  //     case AuthorizationStatus.authorized:
  //       final AppleIdCredential = result.credential!;
  //       final oAuthCredential = OAuthProvider('apple.com');
  //       final credential = oAuthCredential.credential(
  //           idToken: String.fromCharCodes(AppleIdCredential.identityToken!));
  //       final UserCredential = await auth.signInWithCredential(credential);
  //       final firebaseUser = UserCredential.user!;
  //       if (scopes.contains(Scope.fullName)) {
  //         final fullName = AppleIdCredential.fullName;
  //         if (fullName != null &&
  //             fullName.givenName != null &&
  //             fullName.familyName != null) {
  //           final displayName = '${fullName.givenName}${fullName.familyName}';
  //           await firebaseUser.updateDisplayName(displayName);
  //         }
  //       }
  //       return firebaseUser;
  //     case AuthorizationStatus.error:
  //       throw PlatformException(
  //           code: 'ERROR_AUTHORIZATION_DENIED',
  //           message: result.error.toString());

  //     case AuthorizationStatus.cancelled:
  //       throw PlatformException(
  //           code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
  //     default:
  //       throw UnimplementedError();
  //   }
  // }
}
