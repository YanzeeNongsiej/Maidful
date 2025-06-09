// ✅ OTPScreen.dart (Refactored for smoother UX and better efficiency)
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ibitf_app/home.dart';
import 'package:ibitf_app/signup.dart';

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
  late String _verificationId;
  late int? _resendToken;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _resendToken = widget.resendToken;

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<Map<String, String>?> promptUserForEmailPassword(
      BuildContext context) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Email and Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // Cancel
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                if (email.isEmpty || password.isEmpty) {
                  // Show error or disable button until filled
                  return;
                }
                Navigator.pop(context, {'email': email, 'password': password});
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _postLoginRoute(String phone, dynamic credential) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        // final emailPassword = await promptUserForEmailPassword(context);
        // final email = emailPassword!['email']!;
        // final password = emailPassword['password']!;
        // UserCredential emailCredential = await FirebaseAuth.instance
        //     .signInWithEmailAndPassword(email: email, password: password);
        // await emailCredential.user?.linkWithCredential(credential);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
          (route) => false,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SignUp(phone: phone)),
        );
      }
    } catch (e) {
      _showToast("Error checking user: $e");
    }
  }

  Future<void> _verifyOTP() async {
    final smsCode = otpController.text.trim();
    if (smsCode.isEmpty) {
      _showToast("Please enter the OTP.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      await _postLoginRoute(widget.phone, credential);
    } on FirebaseAuthException catch (e) {
      _showToast("Invalid OTP: ${e.message}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    if (secondsRemaining > 0) return;

    setState(() {
      secondsRemaining = 60;
      _startTimer();
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91${widget.phone}",
        forceResendingToken: _resendToken,
        verificationCompleted: (_) {},
        verificationFailed: (e) =>
            _showToast("Verification failed: ${e.message}"),
        codeSent: (verificationId, resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
          });
          _showToast("OTP resent successfully.");
        },
        codeAutoRetrievalTimeout: (_) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showToast("Error resending OTP: $e");
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
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
                      onPressed: _verifyOTP,
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
                  onPressed: _resendOTP,
                  child: const Text("Resend OTP"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
