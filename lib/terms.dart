import 'package:flutter/material.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:styled_text/styled_text.dart';

class Terms extends StatefulWidget {
  int when = 1;
  Terms({super.key, when});

  @override
  State<Terms> createState() => _MyTerms();
}

class _MyTerms extends State<Terms> {
  String content = "";
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    GlobalVariables.instance.selected == 'English'
        ? content =
            '<bold>Welcome to MaidFul!</bold>\n\nThis app is designed to help connect employers with household workers, such as maids. By using this app, you agree to the following terms and conditions...'
        : content =
            '<bold>Ngi pdiang sngewbha ia phi sha ka MaidFul!</bold>\n\nIa kane ka app la shna khnang ban iarap ban pyniasoh ia ki nongpyntreikam...';

    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((onValue) {
      setState(() {});
    });
  }

  void _onAgreePressed() {
    if (!isChecked) {
      // Show Snackbar if not agreed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You must accept the terms and conditions before proceeding.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Navigator.pop(context); // Pop the page if agreed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 8,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.shade100, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description,
                            color: Colors.blueAccent, size: 30),
                        const SizedBox(width: 8),
                        Text(
                          'Terms and Conditions',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.blueAccent.withOpacity(0.5),
                      thickness: 1.5,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity, // Ensures proper width
                      child: SingleChildScrollView(
                        child: StyledText(
                          text: content,
                          tags: {
                            'bold': StyledTextTag(
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          },
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: widget.when == 1 ? true : false,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Center(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  GlobalVariables.instance.xmlHandler
                                      .getString('read'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: _onAgreePressed,
                              child: Text(
                                GlobalVariables.instance.xmlHandler
                                    .getString('agree'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
