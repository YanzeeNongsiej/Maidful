// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:ibitf_app/razorpay_payment.dart';
// // Import the Razorpay payment page

// class WalletPage extends StatefulWidget {
//   const WalletPage({super.key});

//   @override
//   State<WalletPage> createState() => _WalletPageState();
// }

// class _WalletPageState extends State<WalletPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   double _walletBalance = 0.0;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _listenToWalletBalance();
//   }

//   void _listenToWalletBalance() {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showAlertDialog('Error', 'User not logged in.');
//       return;
//     }

//     _firestore.collection('wallets').doc(userId).snapshots().listen((snapshot) {
//       if (snapshot.exists && snapshot.data() != null) {
//         setState(() {
//           _walletBalance = (snapshot.data()?['balance'] ?? 0.0).toDouble();
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _walletBalance = 0.0;
//           _isLoading = false;
//         });
//       }
//     }, onError: (error) {
//       setState(() {
//         _isLoading = false;
//       });
//       print('Error listening to wallet balance: $error');
//       _showAlertDialog('Error', 'Failed to load wallet balance: $error');
//     });
//   }

//   Future<void> _addFunds() async {
//     TextEditingController amountController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add Funds to Wallet'),
//           content: TextField(
//             controller: amountController,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               labelText: 'Amount (INR)',
//               hintText: 'e.g., 500',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close the dialog
//                 final double? amount = double.tryParse(amountController.text);
//                 if (amount != null && amount > 0) {
//                   final result = await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => RazorpayPaymentPage(
//                         amount: amount,
//                         description: 'Wallet Top-up',
//                         purpose: 'wallet_topup',
//                       ),
//                     ),
//                   );
//                   if (result == true) {
//                     _showAlertDialog(
//                         'Success', 'Wallet topped up successfully!');
//                   } else {
//                     _showAlertDialog(
//                         'Failed', 'Wallet top-up failed or cancelled.');
//                   }
//                 } else {
//                   _showAlertDialog('Invalid Amount',
//                       'Please enter a valid positive amount.');
//                 }
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showAlertDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Wallet'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Card(
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     color: Colors.blueAccent.shade100,
//                     child: Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Column(
//                         children: [
//                           const Text(
//                             'Current Balance',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white70,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             '₹${_walletBalance.toStringAsFixed(2)}',
//                             style: const TextStyle(
//                               fontSize: 48,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   ElevatedButton.icon(
//                     onPressed: _addFunds,
//                     icon: const Icon(Icons.add_circle_outline),
//                     label: const Text('Add Funds'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       textStyle: const TextStyle(fontSize: 18),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Expanded(
//                     child: Card(
//                       elevation: 5,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Transaction History',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Expanded(
//                               child: StreamBuilder<QuerySnapshot>(
//                                 stream: _firestore
//                                     .collection('transactions')
//                                     .where('userId',
//                                         isEqualTo: _auth.currentUser?.uid)
//                                     .snapshots(), // Removed .orderBy('timestamp', descending: true)
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return const Center(
//                                         child: CircularProgressIndicator());
//                                   }
//                                   if (snapshot.hasError) {
//                                     return Center(
//                                         child:
//                                             Text('Error: ${snapshot.error}'));
//                                   }
//                                   if (!snapshot.hasData ||
//                                       snapshot.data!.docs.isEmpty) {
//                                     return const Center(
//                                         child: Text('No transactions yet.'));
//                                   }

//                                   // Sort the documents in memory
//                                   List<DocumentSnapshot> sortedDocs =
//                                       snapshot.data!.docs.toList();
//                                   sortedDocs.sort((a, b) {
//                                     Timestamp tsA =
//                                         a['timestamp'] ?? Timestamp.now();
//                                     Timestamp tsB =
//                                         b['timestamp'] ?? Timestamp.now();
//                                     return tsB
//                                         .compareTo(tsA); // Descending order
//                                   });

//                                   return ListView.builder(
//                                     itemCount: sortedDocs.length,
//                                     itemBuilder: (context, index) {
//                                       var transaction = sortedDocs[index].data()
//                                           as Map<String, dynamic>;
//                                       Timestamp timestamp =
//                                           transaction['timestamp'] ??
//                                               Timestamp.now();
//                                       String formattedDate =
//                                           '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year} ${timestamp.toDate().hour}:${timestamp.toDate().minute}';
//                                       return Card(
//                                         margin: const EdgeInsets.symmetric(
//                                             vertical: 8.0),
//                                         elevation: 2,
//                                         child: ListTile(
//                                           leading: Icon(
//                                             transaction['purpose'] ==
//                                                     'wallet_topup'
//                                                 ? Icons.account_balance_wallet
//                                                 : Icons.payments,
//                                             color: transaction['status'] ==
//                                                     'success'
//                                                 ? Colors.green
//                                                 : Colors.red,
//                                           ),
//                                           title: Text(
//                                             '${transaction['description']} - ₹${transaction['amount'].toStringAsFixed(2)}',
//                                             style: const TextStyle(
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                           subtitle: Text(
//                                             'Status: ${transaction['status'].toUpperCase()}\nDate: $formattedDate',
//                                           ),
//                                           trailing: transaction['status'] ==
//                                                   'success'
//                                               ? const Icon(Icons.check_circle,
//                                                   color: Colors.green)
//                                               : const Icon(Icons.cancel,
//                                                   color: Colors.red),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
