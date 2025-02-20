import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/model/service.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:intl/intl.dart';
import 'package:multiselect/multiselect.dart';

import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/changelang.dart';

class JobResume extends StatefulWidget {
  const JobResume({super.key});

  @override
  _JobResumeState createState() => _JobResumeState();
}

class _JobResumeState extends State<JobResume>
    with SingleTickerProviderStateMixin {
  Future<List<String>>? _futureSkills;
  final fromTimeController = TextEditingController();
  final toTimeController = TextEditingController();
  final whcontroller = TextEditingController();
  final whController1 = TextEditingController();
  final TextEditingController shiftcont = TextEditingController();
  List<String> timeEntries = [];

  final ratecontroller = TextEditingController();
  static const IconData rupeeSymbol =
      IconData(0x20B9, fontFamily: 'MaterialIcons');
  bool dayValid = false,
      timeFromValid = false,
      timeToValid = false,
      servicesValid = false,
      rateValid = false;
  int whcount = 0, maxlinevalue = 1, timingcount = 0, maxlinevalueshift = 1;
  int _selectedTimingValue = 1;
  int _selectedWageValue = 1;
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

  List<String> workHistory = [];
  List<String> shifts = [];
  List<bool> selectedTimings = [false, false, false];

  List<String> timeSlots = [
    for (int i = 0; i < 24; i++)
      "${i % 12 == 0 ? 12 : i % 12} ${i < 12 ? 'AM' : 'PM'}"
  ];
  List<bool> _selectedTimeSlots = List.generate(24, (index) => false);
  bool _selectAll = false;
  Map<String, bool> selectedServices = {};
  Map<String, TextEditingController> rateControllers = {};
  Map<String, List<String>> selectedRates = {};

  TimeOfDay? selectedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;
  // TextDirection textDirection = TextDirection.ltr;
  int defaultValue = 0000;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = false;
  bool finalrate = false;
  List<String> selectedCheckBoxValue = [];
  List<String> selectedDaysValue = [];

  @override
  void initState() {
    super.initState();
    showOptionsDay = true;
    showOptionsHour = true;
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
  }

  // Function to validate if at least one time slot is selected
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

    //fetch only skills from the user
    for (var doc in snapshot.docs) {
      // Get the skill for the selected language

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
    // List<String> res2 = await english(selectedCheckBoxValue, GlobalVariables.instance.selected);
    selectedDaysValue = res;
    daysList = res2;
    if (GlobalVariables.instance.selected == 'Khasi') {
      List<String> englishSkills = [];
      final firestoreInstance = FirebaseFirestore.instance;
      for (String skill in selectedRates.keys) {
        // Query Firebase to find the document where 'Khasi' equals the native skill
        QuerySnapshot query = await firestoreInstance
            .collection('skills')
            .where('Khasi', isEqualTo: skill)
            .get();

        if (query.docs.isNotEmpty) {
          // Extract the 'English' field from the document
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
      // Remove the old keys
      for (String oldKey in oldKeys) {
        selectedRates.remove(oldKey);
      }
      for (String service in selectedRates.keys) {
        selectedRates[service]![1] =
            getKeyFromValue(selectedRates[service]![1])!;
      }
      //selectedCheckBoxValue = englishSkills;
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
      "services": selectedRates,
      "negotiable": _selectedNegoValue == 1 ? "Yes" : "No",
      "work_history": workHistory,
      "ack": false,
      "timestamp": FieldValue.serverTimestamp(),
    };
    isOK = true;

    if (isOK == true) {
      await maidDao()
          .addService(uploadService)
          .whenComplete(
              () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    GlobalVariables.instance.xmlHandler.getString('addedsucc'),
                    style: const TextStyle(fontSize: 20.0),
                  ))))
          .whenComplete(() => Navigator.pop(context));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        GlobalVariables.instance.xmlHandler.getString('error'),
        style: const TextStyle(fontSize: 20.0),
      )));
    }
  }

  void addWH() async {
    //open a dialog box to enter work History..
    whcount = whcount + 1;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                'Add ${GlobalVariables.instance.xmlHandler.getString('workhist')}'),
            content: TextFormField(
              controller: whController1,
              decoration: InputDecoration(
                labelText:
                    GlobalVariables.instance.xmlHandler.getString('workhist'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  workHistory.add(whController1.text);
                  setState(() {
                    maxlinevalue = maxlinevalue + 1;
                    whcontroller.text =
                        "${whcontroller.text}$whcount. ${whController1.text}\n";
                    whController1.clear();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
  }

  void handleClick(String value) async {
    switch (value) {
      case 'Logout':
        await AuthMethods.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LogIn()));
        }
        break;
      case 'Settings':
        break;
    }
  }

  Future<List<Service>> fetchOwnServices() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    List<Service> qs = await maidDao().getOwnServices(userID);
    return qs;
  }

  bool showOptionsDay = false, showOptionsHour = false;
  // void checkPostAvailability() async {
  //   print("_selectedTimingValue:$_selectedTimingValue");
  //   String schdle = "";
  //   if (_selectedTimingValue == 1) {
  //     schdle = "Live-in";
  //   } else if (_selectedTimingValue == 2) {
  //     schdle = "Daily";
  //   } else {
  //     schdle = "Hourly";
  //   }
  //   List<Service> services = await fetchOwnServices();
  //   for (var serv in services) {
  //     if (serv.schedule == schdle) {
  //       print("schdle present");
  //       if (_selectedTimingValue == 1) {
  //         showDialog(
  //             context: context,
  //             builder: (context) {
  //               return AlertDialog(
  //                 title: const Text("Warning"),
  //                 content: Text(
  //                     GlobalVariables.instance.xmlHandler.getString('avail')),
  //               );
  //             });
  //       } else if (_selectedTimingValue == 2) {
  //         String selTimeF = fromTimeController.text;
  //         String selTimeT = toTimeController.text;
  //         if (selTimeF.isNotEmpty && selTimeT.isNotEmpty) {
  //           TimeOfDay selTimeFrom = stringToTimeOfDay(selTimeF),
  //               selTimeTo = stringToTimeOfDay(selTimeT),
  //               timeF = stringToTimeOfDay(
  //                   serv.timing[0].toString().split(' - ')[0]),
  //               timet = stringToTimeOfDay(
  //                   serv.timing[0].toString().split(' - ')[1]);
  //           if (timeIsPresent(selTimeFrom, selTimeTo, timeF, timet)) {
  //             showDialog(
  //                 context: context,
  //                 builder: (context) {
  //                   return AlertDialog(
  //                     title: const Text("Warning"),
  //                     content: Text(GlobalVariables.instance.xmlHandler
  //                         .getString('avail')),
  //                   );
  //                 });
  //           }
  //         }
  //         // return const SizedBox.shrink();
  //         // if(serv.time_from)
  //       } else {
  //         // for hourly
  //         String selTimeF = fromTimeController.text;
  //         String selTimeT = toTimeController.text;
  //         if (selTimeF.isNotEmpty &&
  //             selTimeT.isNotEmpty &&
  //             selectedDaysValue.isNotEmpty) {
  //           for (var d in selectedDaysValue) {
  //             for (var servday in serv.days) {
  //               if (d == servday) {
  //                 TimeOfDay selTimeFrom = stringToTimeOfDay(selTimeF),
  //                     selTimeTo = stringToTimeOfDay(selTimeT),
  //                     timeF = stringToTimeOfDay(
  //                         serv.timing[0].toString().split(' - ')[0]),
  //                     timet = stringToTimeOfDay(
  //                         serv.timing[0].toString().split(' - ')[1]);
  //                 if (timeIsPresent(selTimeFrom, selTimeTo, timeF, timet)) {
  //                   showDialog(
  //                       context: context,
  //                       builder: (context) {
  //                         return AlertDialog(
  //                           title: const Text("Warning"),
  //                           content: Text(GlobalVariables.instance.xmlHandler
  //                               .getString('avail')),
  //                         );
  //                       });
  //                   break;
  //                 }
  //               }
  //             }
  //           }
  //         }
  //         // for hourly
  //         // return const SizedBox.shrink();
  //       }
  //     } else {
  //       print("no post, OK!");
  //     }
  //   }
  // }

  TimeOfDay stringToTimeOfDay(String tod) {
    DateTime date = DateFormat('hh:mm a').parse(tod);
    return TimeOfDay.fromDateTime(date);
  }

  //thisone fix
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
        title: Text(GlobalVariables.instance.xmlHandler.getString('addserv')),
        actions: <Widget>[
          PopupMenuButton<String>(
            icon: CircleAvatar(
              foregroundImage: NetworkImage(AuthMethods.user?.photoURL ?? ''),
            ),
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Settings'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedTimings[0],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTimings[0] = value!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(GlobalVariables
                                        .instance.xmlHandler
                                        .getString('Live-in')),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedTimings[1],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTimings[1] = value!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(GlobalVariables
                                        .instance.xmlHandler
                                        .getString('Daily')),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedTimings[2],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTimings[2] = value!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(GlobalVariables
                                        .instance.xmlHandler
                                        .getString('Hourly')),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
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
                      visible:
                          showOptionsDay, // Show the options only if showOptions is true
                      child: Column(
                        children: [
                          // const Text("Day(s)", textAlign: TextAlign.center),
                          DropDownMultiSelect(
                            validator: (val) {
                              if (selectedDaysValue.isEmpty) {
                                return GlobalVariables.instance.xmlHandler
                                    .getString('selectdays');
                              }
                              return '';
                            },
                            decoration: InputDecoration(
                              // fillColor: Theme.of(context).colorScheme.onPrimary,
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
                      visible:
                          showOptionsHour, // Show the options only if showOptions is true
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
                                  crossAxisCount:
                                      4, // Adjust number of columns as needed
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
                                      padding: EdgeInsets.all(8.0),
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
                                        child: Text(
                                          timeSlots[index],
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Display validation error if no time slot is selected
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  validateTimeSlots() ??
                                      '', // Show error message if invalid
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: Container(
                          //         padding: const EdgeInsets.symmetric(
                          //             vertical: 2.0, horizontal: 30.0),
                          //         decoration: BoxDecoration(
                          //             color: const Color(0xFFedf0f8),
                          //             borderRadius: BorderRadius.circular(30)),
                          //         child: TextFormField(
                          //           maxLines: maxlinevalueshift,
                          //           controller: shiftcont,
                          //           decoration: InputDecoration(
                          //               border: InputBorder.none,
                          //               hintText: 'shift',
                          //               hintStyle: TextStyle(
                          //                   color: Color(0xFFb2b7bf),
                          //                   fontSize: 18.0)),
                          //           readOnly: true,
                          //         ),
                          //       ),
                          //     ),
                          //     Container(
                          //         decoration: const BoxDecoration(
                          //             color: Color.fromARGB(255, 37, 67, 133),
                          //             shape: BoxShape.circle),
                          //         child: IconButton(
                          //             onPressed: () {
                          //               timingcount += 1;
                          //               showDialog(
                          //                 context: context,
                          //                 builder: (BuildContext context) {
                          //                   return AlertDialog(
                          //                     title: Text("Add Timing"),
                          //                     content: Row(
                          //                       mainAxisAlignment:
                          //                           MainAxisAlignment
                          //                               .spaceAround,
                          //                       children: [
                          //                         Expanded(
                          //                           child: Container(
                          //                             padding: const EdgeInsets
                          //                                 .symmetric(
                          //                                 vertical: 2.0,
                          //                                 horizontal: 30.0),
                          //                             decoration: BoxDecoration(
                          //                                 color: const Color(
                          //                                     0xFFedf0f8),
                          //                                 borderRadius:
                          //                                     BorderRadius
                          //                                         .circular(
                          //                                             30)),
                          //                             child: TextFormField(
                          //                               controller:
                          //                                   fromTimeController,
                          //                               decoration: InputDecoration(
                          //                                   border: InputBorder
                          //                                       .none,
                          //                                   hintText: 'From',
                          //                                   hintStyle: TextStyle(
                          //                                       color: Color(
                          //                                           0xFFb2b7bf),
                          //                                       fontSize:
                          //                                           18.0)),
                          //                               readOnly: true,
                          //                               onTap: () async {
                          //                                 final TimeOfDay?
                          //                                     time =
                          //                                     await showTimePicker(
                          //                                   context: context,
                          //                                   initialTime:
                          //                                       TimeOfDay.now(),
                          //                                 );
                          //                                 if (time != null) {
                          //                                   setState(() {
                          //                                     fromTimeController
                          //                                             .text =
                          //                                         time.format(
                          //                                             context);
                          //                                   });
                          //                                 }
                          //                               },
                          //                             ),
                          //                           ),
                          //                         ),
                          //                         Container(
                          //                           padding:
                          //                               const EdgeInsets.only(
                          //                                   left: 10,
                          //                                   right: 10),
                          //                           child: const Text(
                          //                             "-",
                          //                             textAlign:
                          //                                 TextAlign.center,
                          //                           ),
                          //                         ),
                          //                         Expanded(
                          //                           child: Container(
                          //                             padding: const EdgeInsets
                          //                                 .symmetric(
                          //                                 vertical: 2.0,
                          //                                 horizontal: 30.0),
                          //                             decoration: BoxDecoration(
                          //                                 color: const Color(
                          //                                     0xFFedf0f8),
                          //                                 borderRadius:
                          //                                     BorderRadius
                          //                                         .circular(
                          //                                             30)),
                          //                             child: TextFormField(
                          //                               controller:
                          //                                   toTimeController,
                          //                               decoration: InputDecoration(
                          //                                   border: InputBorder
                          //                                       .none,
                          //                                   hintText: 'To',
                          //                                   hintStyle: TextStyle(
                          //                                       color: Color(
                          //                                           0xFFb2b7bf),
                          //                                       fontSize:
                          //                                           18.0)),
                          //                               readOnly: true,
                          //                               onTap: () async {
                          //                                 final TimeOfDay?
                          //                                     time =
                          //                                     await showTimePicker(
                          //                                   context: context,
                          //                                   initialTime:
                          //                                       TimeOfDay.now(),
                          //                                 );
                          //                                 if (time != null) {
                          //                                   setState(() {
                          //                                     toTimeController
                          //                                             .text =
                          //                                         time.format(
                          //                                             context);
                          //                                   });
                          //                                 }
                          //                               },
                          //                             ),
                          //                           ),
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     actions: [
                          //                       TextButton(
                          //                         child: Text("Add"),
                          //                         onPressed: () {
                          //                           if (fromTimeController
                          //                                   .text.isNotEmpty &&
                          //                               toTimeController
                          //                                   .text.isNotEmpty) {
                          //                             setState(() {
                          //                               maxlinevalueshift =
                          //                                   maxlinevalueshift +
                          //                                       1;
                          //                               String data =
                          //                                   "${fromTimeController.text} - ${toTimeController.text}";
                          //                               timeEntries.add(data);
                          //                               shiftcont.text =
                          //                                   "${shiftcont.text}$timingcount. $data\n";
                          //                               fromTimeController
                          //                                   .clear();
                          //                               toTimeController
                          //                                   .clear();
                          //                             });
                          //                             Navigator.pop(context);
                          //                             setState(() {});
                          //                           } else {
                          //                             // Optionally, show a validation error here
                          //                           }
                          //                         },
                          //                       ),
                          //                       TextButton(
                          //                         child: Text("Cancel"),
                          //                         onPressed: () {
                          //                           Navigator.of(context).pop();
                          //                         },
                          //                       ),
                          //                     ],
                          //                   );
                          //                 },
                          //               );
                          //             },
                          //             icon: const Icon(
                          //               Icons.add,
                          //               color: Colors.white,
                          //             ))),
                          //   ],
                          // ),
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
                            // Multi-select Dropdown
                            DropdownButtonFormField<String>(
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
                                              });
                                              this.setState(
                                                  () {}); // Reflect changes in UI
                                            },
                                          ),
                                          Expanded(child: Text(service)),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                              onChanged: (_) {}, // No direct onChanged needed
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Select Services",
                                border: OutlineInputBorder(),
                              ),
                            ),

                            // Display selected services with rate input and service name
                            ...selectedServices.entries
                                .where((entry) => entry.value)
                                .map((entry) {
                              String service = entry.key;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(service,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        // Display selected service
                                        SizedBox(width: 10),
                                        Text("Rate:"),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            controller:
                                                rateControllers[service],
                                            keyboardType: TextInputType.number,
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
                                                  ]; // Initialize with a second item if missing
                                                } else {
                                                  selectedRates[service]![0] =
                                                      value; // Update index 0
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        DropdownButton<String>(
                                          value:
                                              selectedRates[service] != null &&
                                                      selectedRates[service]!
                                                              .length >
                                                          1
                                                  ? selectedRates[service]![
                                                      1] // Use the stored value
                                                  : GlobalVariables
                                                      .instance.xmlHandler
                                                      .getString('perhour'),
                                          items: [
                                            GlobalVariables.instance.xmlHandler
                                                .getString('perhour'),
                                            GlobalVariables.instance.xmlHandler
                                                .getString('perday'),
                                            GlobalVariables.instance.xmlHandler
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
                                                selectedRates[service]!.length <
                                                    2) {
                                              selectedRates[service] = [
                                                "0",
                                                newValue!
                                              ]; // Initialize with a first item if missing
                                            } else {
                                              selectedRates[service]![1] =
                                                  newValue!; // Update index 1
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
                    )

                    // DropDownMultiSelect(
                    //   validator: ($selectedCheckBoxValue) {
                    //     if (selectedCheckBoxValue.isEmpty) {
                    //       return GlobalVariables.instance.xmlHandler
                    //           .getString('selectserv');
                    //     } else {
                    //       servicesValid = true;
                    //       return '';
                    //     }
                    //   },
                    //   decoration: InputDecoration(
                    //     // fillColor: Theme.of(context).colorScheme.onPrimary,
                    //     fillColor: Colors.amber,
                    //     focusColor: Theme.of(context).colorScheme.onPrimary,
                    //     border: const OutlineInputBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(30)),
                    //     ),
                    //     enabledBorder: const OutlineInputBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(30)),
                    //         borderSide:
                    //             BorderSide(color: Colors.grey, width: 1.5)),
                    //     focusedBorder: const OutlineInputBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(30)),
                    //         borderSide: BorderSide(
                    //           color: Colors.blue,
                    //           width: 1.5,
                    //         )),
                    //     errorBorder: const OutlineInputBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(30)),
                    //         borderSide:
                    //             BorderSide(color: Colors.red, width: 1.5)),
                    //     focusedErrorBorder: const OutlineInputBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(30)),
                    //         borderSide:
                    //             BorderSide(color: Colors.grey, width: 1.5)),
                    //   ),
                    //   options: variantsList,
                    //   selectedValues: selectedCheckBoxValue,
                    //   onChanged: (List<String> value) {
                    //     value = selectedCheckBoxValue;
                    //   },
                    //   whenEmpty: GlobalVariables.instance.xmlHandler
                    //       .getString('selectserv'),
                    // ),
                    // const SizedBox(
                    //   height: 30.0,
                    // ),
                    // Column(
                    //   children: [
                    //     Text(
                    //         GlobalVariables.instance.xmlHandler
                    //             .getString('wage'),
                    //         textAlign: TextAlign.center),
                    //     Column(
                    //       children: [
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //           children: [
                    //             Expanded(
                    //               flex: 1,
                    //               child: Row(
                    //                 children: [
                    //                   Radio(
                    //                       value: 1,
                    //                       groupValue: _selectedWageValue,
                    //                       onChanged: (value) {
                    //                         setState(() {
                    //                           _selectedWageValue = value!;
                    //                           //toggleWage(1);
                    //                         });
                    //                       }),
                    //                   Expanded(
                    //                     child: Text(GlobalVariables
                    //                         .instance.xmlHandler
                    //                         .getString('Weekly')),
                    //                   )
                    //                 ],
                    //               ),
                    //             ),
                    //             Expanded(
                    //               flex: 1,
                    //               child: Row(
                    //                 children: [
                    //                   Radio(
                    //                       value: 2,
                    //                       groupValue: _selectedWageValue,
                    //                       onChanged: (value) {
                    //                         setState(() {
                    //                           _selectedWageValue = value!;
                    //                           // toggleWage(2);
                    //                         });
                    //                       }),
                    //                   Expanded(
                    //                       child: Text(GlobalVariables
                    //                           .instance.xmlHandler
                    //                           .getString('Monthly')))
                    //                 ],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(
                    //   height: 30.0,
                    // ),
                    // Column(
                    //   children: [
                    //     Text(
                    //       GlobalVariables.instance.xmlHandler.getString('rate'),
                    //       textAlign: TextAlign.start,
                    //     ),
                    //     Row(
                    //       children: [
                    //         Container(
                    //             decoration: const BoxDecoration(
                    //               color: Color.fromARGB(255, 37, 67, 133),
                    //               borderRadius: BorderRadius.only(
                    //                   bottomLeft: Radius.circular(30),
                    //                   topLeft: Radius.circular(30)),
                    //               // shape: BoxShape.circle
                    //             ),
                    //             child: const Padding(
                    //               padding: EdgeInsets.all(13.0),
                    //               child: Icon(
                    //                 rupeeSymbol,
                    //                 color: Colors.white,
                    //               ),
                    //             )),
                    //         Expanded(
                    //           child: Container(
                    //             padding: const EdgeInsets.symmetric(
                    //                 vertical: 2.0, horizontal: 30.0),
                    //             decoration: const BoxDecoration(
                    //                 color: Color(0xFFedf0f8),
                    //                 borderRadius: BorderRadius.only(
                    //                     bottomRight: Radius.circular(30),
                    //                     topRight: Radius.circular(30))),
                    //             child: TextFormField(
                    //               validator: (value) {
                    //                 if (value == null || value.isEmpty) {
                    //                   return GlobalVariables.instance.xmlHandler
                    //                       .getString('rate');
                    //                 } else {
                    //                   rateValid = true;
                    //                   return null;
                    //                 }
                    //               },
                    //               controller: ratecontroller,
                    //               keyboardType: TextInputType.number,
                    //               decoration: InputDecoration(
                    //                   border: InputBorder.none,
                    //                   hintText: GlobalVariables
                    //                       .instance.xmlHandler
                    //                       .getString('rate'),
                    //                   hintStyle: TextStyle(
                    //                       color: Color(0xFFb2b7bf),
                    //                       fontSize: 18.0)),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    ,
                    const SizedBox(
                      height: 10.0,
                    ),
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
                                          //toggleWage(1);
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
                                          // toggleWage(2);
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
                    const SizedBox(
                      height: 15.0,
                    ),
                    Divider(
                      thickness: 3,
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Column(
                      children: [
                        Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('workhist'),
                          textAlign: TextAlign.start,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 30.0),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFedf0f8),
                                    borderRadius: BorderRadius.circular(30)),
                                child: TextFormField(
                                  maxLines: maxlinevalue,
                                  controller: whcontroller,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: GlobalVariables
                                          .instance.xmlHandler
                                          .getString('nowork'),
                                      hintStyle: TextStyle(
                                          color: Color(0xFFb2b7bf),
                                          fontSize: 18.0)),
                                  readOnly: true,
                                ),
                              ),
                            ),
                            Container(
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 37, 67, 133),
                                    shape: BoxShape.circle),
                                child: IconButton(
                                    onPressed: addWH,
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (selectedDaysValue.isNotEmpty &&
                            validateTimeSlots() == null &&
                            validateSelectedTimings() == null &&
                            finalrate) {
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
                            GlobalVariables.instance.xmlHandler
                                .getString('postserv'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500),
                          ))),
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
