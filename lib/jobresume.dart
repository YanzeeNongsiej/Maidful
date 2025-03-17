import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/controller/chat_controller.dart';
import 'package:ibitf_app/model/jobProfile.dart';
import 'package:ibitf_app/model/service.dart';
import 'package:ibitf_app/notifservice.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multiselect/multiselect.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/changelang.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class JobResume extends StatefulWidget {
  final int kind;
  final String? receiverID;
  JobResume(this.kind, {this.receiverID, Key? key}) : super(key: key);

  @override
  _JobResumeState createState() => _JobResumeState();
}

class _JobResumeState extends State<JobResume>
    with SingleTickerProviderStateMixin {
  List<dynamic> selectedImages = [];
  Future<List<String>>? _futureSkills;
  final fromTimeController = TextEditingController();
  final toTimeController = TextEditingController();

  final remrkcontroller = TextEditingController();

  final TextEditingController shiftcont = TextEditingController();
  String selectedText = '';
  List<String> timeEntries = [];

  final ratecontroller = TextEditingController();
  static const IconData rupeeSymbol =
      IconData(0x20B9, fontFamily: 'MaterialIcons');
  bool dayValid = false,
      timeFromValid = false,
      timeToValid = false,
      servicesValid = false,
      rateValid = false;
  int timingcount = 0, maxlinevalueshift = 1;

  int _selectedNegoValue = 1;
  final _formkey = GlobalKey<FormState>();
  List<String> variantsList = [];
  String perDHM = "per hour";
  List<String> daysList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  List<String> shifts = [];
  List<bool> selectedTimings = [false, false, false, false];

  List<String> timeSlots = [
    for (int i = 0; i < 24; i++)
      "${i % 12 == 0 ? 12 : i % 12} ${i < 12 ? 'AM' : 'PM'}"
  ];
  List<bool> _selectedTimeSlots = List.generate(24, (index) => false);
  bool _selectAll = false;
  Map<String, bool> selectedServices = {};
  Map<String, TextEditingController> rateControllers = {};
  Map<String, List<String>> selectedRates = {};
  late QuerySnapshot qs;
  bool isLoading = true;
  TimeOfDay? selectedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;

  int defaultValue = 0000;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = false;
  bool finalrate = false;
  List<String> selectedCheckBoxValue = [];
  List<String> selectedDaysValue = [];
  final ChatController chatcontroller = ChatController();
  @override
  void initState() {
    showOptionsDay = true;
    showOptionsHour = true;
    super.initState();

    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((a) {
      daysList[0] = GlobalVariables.instance.xmlHandler.getString('Monday');
      daysList[1] = GlobalVariables.instance.xmlHandler.getString('Tuesday');
      daysList[2] = GlobalVariables.instance.xmlHandler.getString('Wednesday');
      daysList[3] = GlobalVariables.instance.xmlHandler.getString('Thursday');
      daysList[4] = GlobalVariables.instance.xmlHandler.getString('Friday');
      daysList[5] = GlobalVariables.instance.xmlHandler.getString('Saturday');
      daysList[6] = GlobalVariables.instance.xmlHandler.getString('Sunday');
      _futureSkills = getSkills();
      setState(() {});
    });
    if (widget.kind == 2) {
      fetchOwnServices();
      setState(() {});
    }
  }

  String? validateTimeSlots() {
    if (!_selectedTimeSlots.contains(true)) {
      return '*Please select at least one time slot';
    }
    return null;
  }

  String? validateSelectedTimings() {
    if (!selectedTimings.contains(true)) {
      return GlobalVariables.instance.xmlHandler.getString('multiple');
    }
    return null;
  }

  @override
  void dispose() {
    for (var controller in rateControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<String>> getSkills() async {
    List<String> res = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('skills').get();

    for (var doc in snapshot.docs) {
      if (doc[GlobalVariables.instance.selected] != null) {
        res.add(doc[GlobalVariables.instance.selected]);
      }
    }
    return res;
  }

  toEnglish() async {
    List<String> res =
        await english(selectedDaysValue, GlobalVariables.instance.selected);
    List<String> res2 =
        await english(daysList, GlobalVariables.instance.selected);

    selectedDaysValue = res;
    daysList = res2;
    if (GlobalVariables.instance.selected == 'Khasi') {
      List<String> englishSkills = [];
      final firestoreInstance = FirebaseFirestore.instance;
      for (String skill in selectedRates.keys) {
        QuerySnapshot query = await firestoreInstance
            .collection('skills')
            .where('Khasi', isEqualTo: skill)
            .get();

        if (query.docs.isNotEmpty) {
          String englishSkill = query.docs.first.get('English');
          englishSkills.add(englishSkill);
        } else {
          print('No matching skill found for $skill');
        }
      }

      List<String> oldKeys = selectedRates.keys.toList();

      for (int i = 0; i < oldKeys.length; i++) {
        selectedRates[englishSkills[i]] = selectedRates[oldKeys[i]]!;
      }

      for (String oldKey in oldKeys) {
        selectedRates.remove(oldKey);
      }
      for (String service in selectedRates.keys) {
        selectedRates[service]![1] =
            getKeyFromValue(selectedRates[service]![1])!;
      }
    }
  }

  addService() async {
    final User? user = FirebaseAuth.instance.currentUser;
    bool isOK = false;
    await toEnglish();

    Map<String, dynamic> uploadService = {};
    List<String> finaltime = [
      for (int i = 0; i < timeSlots.length; i++)
        if (_selectedTimeSlots[i]) timeSlots[i]
    ];
    uploadService = {
      "userid": user?.uid,
      "schedule": selectedTimings,
      "days": selectedDaysValue,
      "timing": finaltime,
      "services": GlobalVariables.instance.userrole == 1
          ? selectedRates
          : selectedServices.keys,
      "negotiable": _selectedNegoValue == 1 ? "Yes" : "No",
      "remarks": remrkcontroller.text,
      "ack": false,
      "timestamp": FieldValue.serverTimestamp(),
    };
    isOK = true;

    if (widget.kind == 1) {
      if (GlobalVariables.instance.userrole == 1) {
        await maidDao()
            .addService(uploadService)
            .whenComplete(() =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  GlobalVariables.instance.xmlHandler.getString('addedsucc'),
                  style: const TextStyle(fontSize: 20.0),
                ))))
            .whenComplete(() {
          Navigator.pop(context);
          setState(() {});
        });
      } else {
        //upload images and add the urls to uploadService
        List<String> imageUrls = await uploadImagesToFirebase(selectedImages);
        uploadService["imageurl"] = imageUrls;
        await maidDao()
            .addJobProfile(uploadService)
            .whenComplete(() =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  GlobalVariables.instance.xmlHandler.getString('addedsucc'),
                  style: const TextStyle(fontSize: 20.0),
                ))))
            .whenComplete(() {
          Navigator.pop(context);
          setState(() {});
        });
      }
    } else if (widget.kind == 2) {
      if (GlobalVariables.instance.userrole == 1) {
        await maidDao()
            .updateServiceByUserId(user!.uid, uploadService)
            .whenComplete(() =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  GlobalVariables.instance.xmlHandler.getString('updatesucc'),
                  style: const TextStyle(fontSize: 20.0),
                ))))
            .whenComplete(() {
          Navigator.pop(context);
          setState(() {});
        });
      } else {
        await maidDao()
            .updateJobByUserId(user!.uid, uploadService)
            .whenComplete(() =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  GlobalVariables.instance.xmlHandler.getString('updatesucc'),
                  style: const TextStyle(fontSize: 20.0),
                ))))
            .whenComplete(() {
          Navigator.pop(context);
          setState(() {});
        });
      }
    } else if (widget.kind == 3) {
      uploadService['userid'] = user!.uid;
      uploadService['receiverid'] = widget.receiverID;
      uploadService['status'] = 1;
      String ackid;
      ackid = await maidDao()
          .addAck(uploadService)
          .whenComplete(
              () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    GlobalVariables.instance.xmlHandler.getString('addedsucc'),
                    style: const TextStyle(fontSize: 20.0),
                  ))))
          .whenComplete(() => Navigator.pop(context));

      setState(() {});
      print(ackid);
      await chatcontroller.sendMessage(widget.receiverID!, "@ck", ackid, false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        GlobalVariables.instance.xmlHandler.getString('error'),
        style: const TextStyle(fontSize: 20.0),
      )));
    }
  }

  Future<List<String>> uploadImagesToFirebase(List<dynamic> images) async {
    List<String> imageUrls = [];

    if (images.isEmpty) return imageUrls; // Return empty list if no images

    for (var image in images) {
      try {
        // If it's an existing URL (String), just add it to the list
        if (image is String) {
          imageUrls.add(image);
          continue; // Skip processing, as it's already uploaded
        }

        // Otherwise, it's a new File that needs compression & upload
        File compressedImage = await compressImage(image);

        // Generate a filename with user’s name
        String name =
            await getNameFromId(FirebaseAuth.instance.currentUser!.uid);
        String fileName = "$name${DateTime.now().millisecondsSinceEpoch}.jpg";

        Reference storageRef =
            FirebaseStorage.instance.ref().child("job_images/$fileName");

        await storageRef.putFile(compressedImage);
        String imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return imageUrls;
  }

  void fetchOwnServices() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    if (GlobalVariables.instance.userrole == 1) {
      List<Service> qs = await maidDao().getOwnServices('services', userID);
      for (var serv in qs) {
        remrkcontroller.text = serv.remarks;
        selectedTimings = serv.schedule;
        selectedDaysValue = serv.days;
        _selectedNegoValue = (serv.nego == 'Yes' ? 1 : 2);
        selectedRates = serv.services;
        for (var i in selectedRates.keys) {
          selectedServices[i] = true;
          selectedText == ''
              ? selectedText = i
              : selectedText = '$selectedText, $i';
          rateControllers[i] = TextEditingController();
          rateControllers[i]!.text = selectedRates[i]![0];
        }
        _selectedTimeSlots = List.generate(24, (index) {
          String slot = timeSlots[index];
          return serv.timing.contains(slot);
        });
        finalrate = true;
      }
    } else {
      List<JobProfile> qs =
          await maidDao().getLatestJobProfile('jobprofile', userID);
      for (var serv in qs) {
        remrkcontroller.text = serv.remarks;
        selectedTimings = serv.schedule;
        selectedDaysValue = serv.days;
        _selectedNegoValue = (serv.nego == 'Yes' ? 1 : 2);
        List<String> res = serv.services;
        for (var i in res) {
          selectedServices[i] = true;
          selectedText == ''
              ? selectedText = i
              : selectedText = '$selectedText, $i';
        }
        _selectedTimeSlots = List.generate(24, (index) {
          String slot = timeSlots[index];
          return serv.timing.contains(slot);
        });
        finalrate = true;
        selectedImages.addAll(serv.imageUrl);
      }
    }

    setState(() {});
  }

  bool showOptionsDay = false, showOptionsHour = false;

  TimeOfDay stringToTimeOfDay(String tod) {
    DateTime date = DateFormat('hh:mm a').parse(tod);
    return TimeOfDay.fromDateTime(date);
  }

  bool timeIsPresent(todSelTime, selTimeTo, timeF, timet) {
    print(
        "todseltime:${timeToInteger(todSelTime)}\nselTimeTo:${timeToInteger(selTimeTo)}\ntimeF:${timeToInteger(timeF)}\ntimet:${timeToInteger(timet)}\n");

    if ((timeToInteger(todSelTime) >= timeToInteger(timeF) &&
            timeToInteger(todSelTime) < timeToInteger(timet)) ||
        (timeToInteger(selTimeTo) > timeToInteger(timeF) &&
            timeToInteger(selTimeTo) <= timeToInteger(timet)) ||
        (timeToInteger(todSelTime) <= timeToInteger(timeF) &&
            timeToInteger(selTimeTo) >= timeToInteger(timet))) {
      return true;
    } else {
      return false;
    }
  }

  int timeToInteger(timeVar) {
    var min = "";
    if (timeVar.minute.toString().length == 1) {
      min = "0${timeVar.minute}";
    } else {
      min = timeVar.minute.toString();
    }
    print("minute:$min");
    return int.tryParse("${timeVar.hour}$min") ?? defaultValue;
  }

  void toggleTimings(int i) {
    if (i == 2) {
      setState(() {
        showOptionsHour = true;
        showOptionsDay = false;
      });
    } else if (i == 3) {
      setState(() {
        showOptionsHour = true;
        showOptionsDay = true;
      });
    } else {
      setState(() {
        showOptionsDay = false;
        showOptionsHour = false;
      });
    }
  }

  Future<QuerySnapshot> fetchChats() async {
    QuerySnapshot qs = await maidDao().getAllMaids();
    return qs;
  }

  String? getKeyFromValue(String targetValue) {
    List<String> keys = ["perday", "perhour", "permonth"];
    String res;
    for (String key in keys) {
      if (GlobalVariables.instance.xmlHandler.getString(key) == targetValue) {
        Map<String, String> formattedKeys = {
          "perhour": "per hour",
          "perday": "per day",
          "permonth": "per month"
        };

        res = formattedKeys[key] ?? key;
        return res;
      }
    }
    return null;
  }

  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, // Use .absolute.path for safety
      targetPath,
      quality: 50, // Adjust quality (higher = better quality, larger size)
    );

    if (compressedXFile != null) {
      return File(compressedXFile.path); // Convert XFile to File
    } else {
      return file; // Return original file if compression fails
    }
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      for (XFile file in pickedFiles) {
        File compressedFile =
            await compressImage(File(file.path)); // Corrected usage
        setState(() {
          selectedImages.add(compressedFile); // Add as File
        });
      }
    }
  }

  Widget buildSelectedImagesGrid() {
    return selectedImages.isNotEmpty
        ? SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                var image = selectedImages[index];

                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: image is File // Check if local file or URL
                            ? Image.file(image,
                                width: 80, height: 80, fit: BoxFit.cover)
                            : Image.network(image,
                                width: 80, height: 80, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImages.removeAt(index);
                          });
                        },
                        child: Icon(Icons.cancel, color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        : Text("No images selected", style: TextStyle(color: Colors.grey));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.red,
        title: widget.kind == 1
            ? Text(GlobalVariables.instance.xmlHandler.getString('addserv'))
            : widget.kind == 2
                ? Text(
                    GlobalVariables.instance.xmlHandler.getString('editserv'))
                : Text(
                    GlobalVariables.instance.xmlHandler.getString('hiringdet')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('sched'),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GridView.builder(
                          shrinkWrap:
                              true, // Ensures it only takes necessary space
                          physics:
                              NeverScrollableScrollPhysics(), // Disables inner scrolling
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 items per row
                            childAspectRatio:
                                3.5, // Adjusts item width & height ratio
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: 4, // Total options
                          itemBuilder: (context, index) {
                            List<String> timingOptions = [
                              'Live-in',
                              'Daily',
                              'Hourly',
                              'onetime'
                            ];

                            return Row(
                              children: [
                                Checkbox(
                                  value: selectedTimings[index],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTimings[index] = value!;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    GlobalVariables.instance.xmlHandler
                                        .getString(timingOptions[index]),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          validateSelectedTimings() ?? '',
                          style: TextStyle(
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Divider(
                      thickness: 3,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Visibility(
                      visible: showOptionsDay,
                      child: Column(
                        children: [
                          DropDownMultiSelect(
                            validator: (val) {
                              if (selectedDaysValue.isEmpty) {
                                return GlobalVariables.instance.xmlHandler
                                    .getString('selectdays');
                              }
                              return '';
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.amber,
                              focusColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.5)),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 1.5,
                                  )),
                              errorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide: BorderSide(
                                      color: Colors.red, width: 1.5)),
                              focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.5)),
                            ),
                            options: daysList,
                            selectedValues: selectedDaysValue,
                            onChanged: (List<String> value) {
                              value = selectedDaysValue;
                            },
                            whenEmpty: GlobalVariables.instance.xmlHandler
                                .getString('selectdays'),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Divider(
                            thickness: 3,
                          ),
                          const SizedBox(
                            height: 15.0,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: showOptionsHour,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                GlobalVariables.instance.xmlHandler
                                    .getString('timing'),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Checkbox(
                                value: _selectAll,
                                onChanged: (value) {
                                  setState(() {
                                    _selectAll = value!;
                                    for (int i = 0;
                                        i < _selectedTimeSlots.length;
                                        i++) {
                                      _selectedTimeSlots[i] = _selectAll;
                                    }
                                  });
                                },
                              ),
                              Text("Select All"),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 2.5,
                                ),
                                itemCount: timeSlots.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTimeSlots[index] =
                                            !_selectedTimeSlots[index];
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: _selectedTimeSlots[index]
                                                ? Colors.blue
                                                : Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: _selectedTimeSlots[index]
                                            ? Colors.blue.withOpacity(0.3)
                                            : Colors.transparent,
                                      ),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            timeSlots[index],
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  validateTimeSlots() ?? '',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Divider(
                            thickness: 3,
                          ),
                          const SizedBox(
                            height: 15.0,
                          )
                        ],
                      ),
                    ),
                    FutureBuilder<List<String>>(
                      future: _futureSkills,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text("No services available"));
                        }

                        variantsList = snapshot.data!;
                        print("my list is $variantsList");

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              hint: Text(selectedText),
                              validator: (value) {
                                if (!selectedServices.containsValue(true)) {
                                  return 'Please select at least one service';
                                }
                                return null;
                              },
                              items: variantsList.map((String service) {
                                return DropdownMenuItem<String>(
                                  value: service,
                                  child: StatefulBuilder(
                                    builder: (context, setState) {
                                      return Row(
                                        children: [
                                          Checkbox(
                                            value: selectedServices[service] ??
                                                false,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                selectedServices[service] =
                                                    value ?? false;
                                                selectedText = '';
                                                for (var i
                                                    in selectedServices.keys) {
                                                  if (selectedServices[i] ==
                                                      true) {
                                                    selectedText == ''
                                                        ? selectedText = i
                                                        : selectedText =
                                                            '$selectedText, $i';
                                                  }
                                                }
                                              });
                                              this.setState(() {});
                                            },
                                          ),
                                          Expanded(child: Text(service)),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                              onChanged: (_) {},
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Select Services",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            if (GlobalVariables.instance.userrole == 1)
                              ...selectedServices.entries
                                  .where((entry) => entry.value)
                                  .map((entry) {
                                String service = entry.key;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(service,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
                                          Text("Rate:"),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: TextFormField(
                                              textAlignVertical:
                                                  TextAlignVertical.top,
                                              controller:
                                                  rateControllers[service],
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                icon: Icon(rupeeSymbol),
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 16),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  finalrate = false;
                                                  return 'Please enter a rate';
                                                }
                                                if (double.tryParse(value) ==
                                                    null) {
                                                  finalrate = false;
                                                  return 'Please enter a valid number';
                                                }
                                                finalrate = true;
                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  finalrate = true;
                                                  if (selectedRates[service] ==
                                                          null ||
                                                      selectedRates[service]!
                                                          .isEmpty) {
                                                    selectedRates[service] = [
                                                      value,
                                                      GlobalVariables
                                                          .instance.xmlHandler
                                                          .getString('perhour')
                                                    ];
                                                  } else {
                                                    selectedRates[service]![0] =
                                                        value;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          DropdownButton<String>(
                                            value: selectedRates[service] !=
                                                        null &&
                                                    selectedRates[service]!
                                                            .length >
                                                        1
                                                ? selectedRates[service]![1]
                                                : GlobalVariables
                                                    .instance.xmlHandler
                                                    .getString('perhour'),
                                            items: [
                                              GlobalVariables
                                                  .instance.xmlHandler
                                                  .getString('perhour'),
                                              GlobalVariables
                                                  .instance.xmlHandler
                                                  .getString('perday'),
                                              GlobalVariables
                                                  .instance.xmlHandler
                                                  .getString('permonth')
                                            ].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              if (selectedRates[service] ==
                                                      null ||
                                                  selectedRates[service]!
                                                          .length <
                                                      2) {
                                                selectedRates[service] = [
                                                  "0",
                                                  newValue!
                                                ];
                                              } else {
                                                selectedRates[service]![1] =
                                                    newValue!;
                                              }

                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    if (GlobalVariables.instance.userrole == 1)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Radio(
                                        value: 1,
                                        groupValue: _selectedNegoValue,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedNegoValue = value!;
                                          });
                                        }),
                                    Expanded(
                                      child: Text(GlobalVariables
                                          .instance.xmlHandler
                                          .getString('nego')),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    Radio(
                                        value: 2,
                                        groupValue: _selectedNegoValue,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedNegoValue = value!;
                                          });
                                        }),
                                    Expanded(
                                        child: Text(GlobalVariables
                                            .instance.xmlHandler
                                            .getString('nonnego')))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    Divider(
                      thickness: 3,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    if (GlobalVariables.instance.userrole == 2 &&
                        [1, 2].contains(widget.kind))
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Upload photos of the house/rooms/garden/etc that requires servicing(Optional)",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          ElevatedButton.icon(
                            onPressed: pickImages,
                            icon: Icon(Icons.upload_file),
                            label: Text("Select Images"),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),

                          const SizedBox(height: 10.0),

                          // Preview Selected Images
                          buildSelectedImagesGrid(),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                          color: const Color(0xFFedf0f8),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextFormField(
                        maxLines: 5,
                        controller: remrkcontroller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "Enter Remarks",
                            labelStyle: TextStyle(
                              color: Color(0xFFb2b7bf),
                              fontSize: 18.0,
                            ),
                            alignLabelWithHint: true),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (GlobalVariables.instance.userrole == 1 &&
                            selectedDaysValue.isNotEmpty &&
                            validateTimeSlots() == null &&
                            validateSelectedTimings() == null &&
                            finalrate) {
                          addService();
                        } else if (GlobalVariables.instance.userrole == 2 &&
                            selectedDaysValue.isNotEmpty &&
                            validateTimeSlots() == null &&
                            validateSelectedTimings() == null) {
                          print('all working');
                          addService();
                        } else {
                          print(
                              '${selectedDaysValue.isNotEmpty}${validateTimeSlots()} ${validateSelectedTimings()} $finalrate');
                          setState(() {});
                        }
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              vertical: 13.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                              color: const Color(0xFF273671),
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                              child: Text(
                            widget.kind == 1
                                ? GlobalVariables.instance.xmlHandler
                                    .getString('postserv')
                                : widget.kind == 2
                                    ? GlobalVariables.instance.xmlHandler
                                        .getString('editserv')
                                    : GlobalVariables.instance.xmlHandler
                                        .getString('sendack'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500),
                          ))),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
