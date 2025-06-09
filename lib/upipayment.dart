import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';

class UpiPaymentPage extends StatefulWidget {
  @override
  _UpiPaymentPageState createState() => _UpiPaymentPageState();
}

class _UpiPaymentPageState extends State<UpiPaymentPage> {
  late Future<List<UpiApp>> _appsFuture;
  final UpiIndia _upiIndia = UpiIndia();
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String paymentStatus = '';

  @override
  void initState() {
    super.initState();
    _appsFuture = _upiIndia.getAllUpiApps(mandatoryTransactionId: false);
  }

  Future<void> _startTransaction(UpiApp app) async {
    final upiId = _upiIdController.text.trim();
    final amountText = _amountController.text.trim();

    if (upiId.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both UPI ID and amount.")),
      );
      return;
    }

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid amount.")),
      );
      return;
    }

    setState(() => paymentStatus = 'Processing...');

    UpiResponse response = await _upiIndia.startTransaction(
      app: app,
      receiverUpiId: upiId,
      receiverName: 'Service Provider',
      transactionRefId: 'TID${DateTime.now().millisecondsSinceEpoch}',
      transactionNote: 'Service Payment',
      amount: amount,
    );

    setState(() {
      paymentStatus = "Status: ${response.status ?? 'Unknown'}\n"
          "TxnId: ${response.transactionId ?? 'N/A'}";
    });

    // Optional: Navigate after success
    if (response.status?.toLowerCase() == 'success') {
      // TODO: Ask for rating or navigate
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay with UPI')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _upiIdController,
              decoration: InputDecoration(
                labelText: 'Receiver UPI ID',
                hintText: 'e.g. someone@okaxis',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (INR)',
                hintText: 'e.g. 200',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            Text("Select a UPI app:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            FutureBuilder<List<UpiApp>>(
              future: _appsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                if (snapshot.data!.isEmpty) return Text("No UPI apps found.");

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: snapshot.data!.map((app) {
                    return GestureDetector(
                      onTap: () => _startTransaction(app),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.memory(app.icon, height: 60),
                          SizedBox(height: 4),
                          Text(app.name, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 20),
            if (paymentStatus.isNotEmpty)
              Text(paymentStatus, style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
