import 'package:flutter/material.dart';
import 'package:ibitf_app/notifservice.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ibitf_app/singleton.dart'; // Assuming GlobalVariables is here

class RazorpayPaymentPage extends StatefulWidget {
  final double? amount; // Made nullable
  final String description;
  final String purpose; // 'service_payment' or 'wallet_topup'
  final String? receiverId; // Required for service_payment

  const RazorpayPaymentPage({
    super.key,
    this.amount, // Now optional
    required this.description,
    required this.purpose,
    this.receiverId,
  });

  @override
  State<RazorpayPaymentPage> createState() => _RazorpayPaymentPageState();
}

class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  late Razorpay _razorpay;
  String _paymentStatus = '';
  bool _isLoading = false;
  final TextEditingController _amountInputController = TextEditingController();

  // Replace with your actual Razorpay Key ID
  // You should get this from your Razorpay Dashboard
  // For security, consider fetching this from a backend or environment variables
  // rather than hardcoding in a production app.
  static const String RAZORPAY_KEY_ID =
      "rzp_test_7zB32iIOT6WpL8"; // **IMPORTANT: Replace this**

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // If an amount is provided, automatically open checkout
    if (widget.amount != null && widget.amount! > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openCheckout(widget.amount!);
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountInputController.dispose();
    super.dispose();
  }

  void _openCheckout(double amountToPay) async {
    if (RAZORPAY_KEY_ID != "rzp_test_7zB32iIOT6WpL8") {
      _showAlertDialog(
        'Configuration Error',
        'HEYYYY! Please replace ${RAZORPAY_KEY_ID} with your actual Razorpay Key ID in razorpay_payment_page.dart.',
      );
      return;
    }

    if (amountToPay <= 0) {
      _showAlertDialog(
          'Invalid Amount', 'Please enter a valid amount to proceed.');
      return;
    }

    setState(() {
      _isLoading = true;
      _paymentStatus = 'Initiating payment...';
    });

    // Convert amount to the smallest currency unit (paise for INR)
    final int amountInPaise = (amountToPay * 100).round();

    var options = {
      'key': RAZORPAY_KEY_ID,
      'amount': amountInPaise, // Amount in paise
      'name': 'Maidful',
      'description': widget.description,
      'prefill': {
        'UserID': FirebaseAuth.instance.currentUser!.uid,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _paymentStatus = 'Error opening checkout: $e';
        _isLoading = false;
      });
      _showAlertDialog('Payment Error', 'Failed to open payment gateway: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _paymentStatus = 'Payment Successful: ${response.paymentId}';
      _isLoading = false;
    });
    // Use the amount from the input controller if widget.amount is null
    final double paidAmount =
        widget.amount ?? double.parse(_amountInputController.text);
    _recordTransaction(
      response.paymentId!,
      'success',
      response.signature,
      response.orderId,
      paidAmount, // Pass the actual paid amount
    );
    _showAlertDialog('Payment Success', 'Payment ID: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _paymentStatus = 'Payment Failed: ${response.code} - ${response.message}';
      _isLoading = false;
    });
    // Use the amount from the input controller if widget.amount is null
    final double attemptedAmount =
        widget.amount ?? (double.tryParse(_amountInputController.text) ?? 0.0);
    _recordTransaction(
      response.code.toString(),
      'failed',
      response.message,
      response.message,
      attemptedAmount, // Pass the attempted amount
    );
    _showAlertDialog('Payment Failed',
        'Error Code: ${response.code}\nDescription: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _paymentStatus = 'External Wallet: ${response.walletName}';
      _isLoading = false;
    });
    _showAlertDialog(
        'External Wallet', 'Selected Wallet: ${response.walletName}');
  }

  Future<void> _recordTransaction(String paymentId, String status,
      String? signature, String? orderId, double transactionAmount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('Error: User not logged in for transaction recording.');
      return;
    }

    final transactionData = {
      'userId': userId,
      'amount': transactionAmount, // Use the actual transaction amount
      'description': widget.description,
      'purpose': widget.purpose,
      'paymentId': paymentId,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'method': 'Razorpay',
      'signature': signature,
      'orderId': orderId,
      'receiverId': widget.receiverId, // Only present for service payments
    };

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .add(transactionData);

      if (status == 'success') {
        if (widget.purpose == 'wallet_topup') {
          await _updateWalletBalance(userId, transactionAmount);
        } else if (widget.purpose == 'service_payment') {
          // You might want to update the service status or mark it as paid
          // For example, update the acknowledgement document
          if (widget.receiverId != null) {
            await _updateAcknowledgementStatus(userId, widget.receiverId!);
          }
        }
      }
    } catch (e) {
      print('Error recording transaction or updating wallet: $e');
      _showAlertDialog('Database Error', 'Failed to record transaction: $e');
    }
  }

  Future<void> _updateWalletBalance(String userId, double amount) async {
    final userWalletRef =
        FirebaseFirestore.instance.collection('wallets').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userWalletRef);

      if (!snapshot.exists) {
        transaction.set(userWalletRef, {'balance': amount});
      } else {
        final currentBalance = snapshot.data()?['balance'] ?? 0.0;
        transaction.update(userWalletRef, {'balance': currentBalance + amount});
      }
    });
    print('Wallet balance updated for $userId by $amount');
  }

  Future<void> _updateAcknowledgementStatus(
      String userId, String receiverId) async {
    // Find the relevant acknowledgement document and update its status to 'paid' (e.g., status 5)
    // This is a placeholder; you'll need to adjust based on your actual acknowledgement structure
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('acknowledgements')
          .where('userid', isEqualTo: userId)
          .where('receiverid', isEqualTo: receiverId)
          .limit(1) // Assuming one active acknowledgement per pair
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference ackDocRef = querySnapshot.docs.first.reference;
        await ackDocRef.update({
          'status': 5,
          'paidAt': FieldValue.serverTimestamp()
        }); // Example status for 'paid'
        print('Acknowledgement status updated to paid for $receiverId');
      }
    } catch (e) {
      print('Error updating acknowledgement status: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                if (title == 'Payment Success') {
                  Navigator.of(context)
                      .pop(true); // Pop payment page with success
                } else if (title == 'Payment Failed' ||
                    title == 'Configuration Error' ||
                    title == 'Invalid Amount') {
                  Navigator.of(context)
                      .pop(false); // Pop payment page with failure
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.amount == null) ...[
                TextField(
                  controller: _amountInputController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter Amount (INR)',
                    hintText: 'e.g., 500',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          final double? enteredAmount =
                              double.tryParse(_amountInputController.text);
                          if (enteredAmount != null && enteredAmount > 0) {
                            _openCheckout(enteredAmount);
                          } else {
                            _showAlertDialog('Invalid Amount',
                                'Please enter a valid positive amount.');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(_isLoading ? 'Processing...' : 'Proceed to Pay'),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Text(
                  'Amount: ₹${widget.amount!.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                _paymentStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _paymentStatus.contains('Successful')
                      ? Colors.green
                      : _paymentStatus.contains('Failed')
                          ? Colors.red
                          : Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              if (widget.amount !=
                  null) // Only show retry if initial amount was provided
                ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => _openCheckout(widget.amount!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(_isLoading ? 'Processing...' : 'Retry Payment'),
                ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Allow user to go back
                },
                child: const Text('Cancel Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
