import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ibitf_app/home.dart';
import 'package:ibitf_app/signup.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestSmsPermission() async {
  final status = await Permission.sms.status;
  if (!status.isGranted) {
    final result = await Permission.sms.request();
    if (result.isGranted) {
      debugPrint("✅ SMS permission granted.");
    } else {
      debugPrint("❌ SMS permission denied.");
      // Optionally show dialog explaining why it's needed
    }
  }
}

class OTPVerificationScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  final int? resendToken;

  const OTPVerificationScreen({
    super.key,
    required this.phone,
    required this.verificationId,
    required this.resendToken,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  int secondsRemaining = 60;
  Timer? _timer;

  // Local variables to hold the verificationId and resendToken
  late String _verificationId;
  late int? _resendToken;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;
    requestSmsPermission();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> postLoginRoute(String phone) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users');
      final result =
          await userRef.where('phone', isEqualTo: phone).limit(1).get();

      if (result.docs.isNotEmpty) {
        // User exists, go to Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
          (route) => false,
        );
      } else {
        // User doesn't exist, go to Signup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignUp()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error checking user: $e");
    }
  }

  void verifyOTP() async {
    String smsCode = otpController.text.trim();

    if (smsCode.isEmpty) return;

    setState(() => isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, // Use the local variable here
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await postLoginRoute(widget.phone);
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: "Invalid OTP: ${e.message}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void resendOTP() async {
    setState(() {
      secondsRemaining = 60;
      startTimer();
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${widget.phone}",
      forceResendingToken: _resendToken, // Use the local variable here
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        Fluttertoast.showToast(msg: "Error: ${e.message}");
        print(e);
      },
      codeSent: (verificationId, resendToken) {
        setState(() {
          _verificationId = verificationId; // Update the local variable
          _resendToken = resendToken; // Update the local variable
        });
      },
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter OTP", style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "6-digit code",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: verifyOTP,
                      child: const Text("Verify"),
                    ),
              const SizedBox(height: 10),
              Text(
                secondsRemaining > 0
                    ? "Resend in $secondsRemaining seconds"
                    : "Didn't get code?",
              ),
              if (secondsRemaining == 0)
                TextButton(
                  onPressed: resendOTP,
                  child: const Text("Resend OTP"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
