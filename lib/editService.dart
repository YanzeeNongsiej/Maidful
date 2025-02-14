import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditServiceScreen extends StatefulWidget {
  final DocumentSnapshot item;

  const EditServiceScreen({Key? key, required this.item}) : super(key: key);

  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  late TextEditingController scheduleController;
  late TextEditingController wageController;
  late TextEditingController negotiableController;
  List<String> selectedDays = [];
  List<String> selectedServices = [];
  Map<String, List<String>> timing = {};

  @override
  void initState() {
    super.initState();
    scheduleController =
        TextEditingController(text: widget.item.get("schedule"));
    wageController = TextEditingController(text: widget.item.get("wage"));
    negotiableController =
        TextEditingController(text: widget.item.get("negotiable"));
    selectedDays = List<String>.from(widget.item.get("days"));
    selectedServices = List<String>.from(widget.item.get("services"));
    Map<String, dynamic> timeData = widget.item.get("timing");
    timing =
        timeData.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  @override
  void dispose() {
    scheduleController.dispose();
    wageController.dispose();
    negotiableController.dispose();
    super.dispose();
  }

  void updateService() {
    FirebaseFirestore.instance
        .collection('services')
        .doc(widget.item.id)
        .update({
      'schedule': scheduleController.text,
      'wage': wageController.text,
      'negotiable': negotiableController.text,
      'days': selectedDays,
      'services': selectedServices,
      'timing': timing,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully!")),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Service")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(labelText: "Schedule"),
              ),
              TextField(
                controller: wageController,
                decoration: const InputDecoration(labelText: "Wage"),
              ),
              TextField(
                controller: negotiableController,
                decoration: const InputDecoration(labelText: "Negotiable"),
              ),
              const SizedBox(height: 20),
              const Text("Timing",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: timing.keys.length,
                itemBuilder: (context, index) {
                  String key = timing.keys.elementAt(index);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$key:"),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                  labelText: "Start Time"),
                              controller:
                                  TextEditingController(text: timing[key]![0]),
                              onChanged: (value) => timing[key]![0] = value,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration:
                                  const InputDecoration(labelText: "End Time"),
                              controller:
                                  TextEditingController(text: timing[key]![1]),
                              onChanged: (value) => timing[key]![1] = value,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateService,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
