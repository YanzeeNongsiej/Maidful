import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/model/service.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:intl/intl.dart';
import 'package:multiselect/multiselect.dart';
import 'package:ibitf_app/xmlhandle.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/changelang.dart';

class JobProfile extends StatefulWidget {
  const JobProfile({super.key});

  @override
  _JobProfileState createState() => _JobProfileState();
}

class _JobProfileState extends State<JobProfile>
    with SingleTickerProviderStateMixin {
  final fromTimeController = TextEditingController();
  final toTimeController = TextEditingController();
  final whcontroller = TextEditingController();
  final whController1 = TextEditingController();
  final ratecontroller = TextEditingController();
  final TextEditingController shiftcont = TextEditingController();
  static const IconData rupeeSymbol =
      IconData(0x20B9, fontFamily: 'MaterialIcons');
  bool dayValid = false,
      timeFromValid = false,
      timeToValid = false,
      servicesValid = false,
      rateValid = false;
  int whcount = 0, maxlinevalue = 1, maxlinevalueshift = 1, timingcount = 0;
  int _selectedTimingValue = 1;
  int _selectedWageValue = 1;
  int _selectedNegoValue = 1;
  final _formkey = GlobalKey<FormState>();
  List<String> variantsList = [
    "Housekeeping",
    "Cooking",
    "Laundry",
    "Babysitting",
    "Elderly Care",
    "Grocery Shopping",
  ];

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
  TimeOfDay? selectedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;
  // TextDirection textDirection = TextDirection.ltr;
  int defaultValue = 0000;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = false;

  List<String> selectedCheckBoxValue = [];
  List<String> selectedDaysValue = [];

  List<String> timeEntries = [];
  @override
  void initState() {
    // TODO: implement initState
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
      getSkills();
      setState(() {});
    });
  }

  void getSkills() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('skills').get();
    int i = 0;
    //fetch only skills from the user
    for (var doc in snapshot.docs) {
      // Get the skill for the selected language

      if (doc[GlobalVariables.instance.selected] != null) {
        print('Prev${variantsList[i]}');
        variantsList[i] = doc[GlobalVariables.instance.selected];
        print(variantsList[i]);
        i = i + 1;
      }
    }
    setState(() {});
  }

  toEnglish() async {
    List<String> res =
        await english(selectedDaysValue, GlobalVariables.instance.selected);
    // List<String> res2 = await english(selectedCheckBoxValue, GlobalVariables.instance.selected);
    selectedDaysValue = res;
    List<String> res2 =
        await english(daysList, GlobalVariables.instance.selected);
    // List<String> res2 = await english(selectedCheckBoxValue, GlobalVariables.instance.selected);
    daysList = res2;
    if (GlobalVariables.instance.selected == 'Khasi') {
      List<String> englishSkills = [];
      final firestoreInstance = FirebaseFirestore.instance;
      for (String skill in selectedCheckBoxValue) {
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
      selectedCheckBoxValue = englishSkills;
    }
  }

  addJobProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    bool isOK = false;
    String wageBasis;
    await toEnglish();
    if (_selectedWageValue == 1) {
      wageBasis = "Weekly";
    } else {
      wageBasis = "Monthly";
    }

    // print(res2);
    Map<String, dynamic> uploadJobProfile = {};
    Map<String, dynamic> timing = {};
    if (_selectedTimingValue == 1) {
      if (servicesValid && rateValid) {
        timeEntries.add("12:00 AM - 11:59 AM");
        // Loop through the list of shift strings
        for (int i = 0; i < timeEntries.length; i++) {
          // Split the string by " - " to get start and end times
          List<String> times = timeEntries[i].split(" - ");

          if (times.length == 2) {
            // Add the times array to the map with a dynamically generated shift key
            timing['shift${i + 1}'] = [times[0], times[1]];
          }
        }
        uploadJobProfile = {
          "userid": user?.uid,
          "schedule": "Live-in",
          "days": daysList,
          "timing": timing,
          "services": selectedCheckBoxValue,
          "negotiable": _selectedNegoValue == 1 ? "1" : "0",
          "wage": wageBasis,
          "rate": ratecontroller.text,
        };
        isOK = true;
      }
    } else if (_selectedTimingValue == 2) {
      if (servicesValid && rateValid) {
        for (int i = 0; i < timeEntries.length; i++) {
          // Split the string by " - " to get start and end times
          List<String> times = timeEntries[i].split(" - ");

          if (times.length == 2) {
            // Add the times array to the map with a dynamically generated shift key
            timing['shift${i + 1}'] = [times[0], times[1]];
          }
        }
        uploadJobProfile = {
          "userid": user?.uid,
          "schedule": "Daily",
          "days": daysList,
          "timing": timing,
          "services": selectedCheckBoxValue,
          "negotiable": _selectedNegoValue == 1 ? "1" : "0",
          "wage": wageBasis,
          "rate": ratecontroller.text,
        };
        isOK = true;
      }
    } else {
      if (servicesValid && dayValid && rateValid) {
        for (int i = 0; i < timeEntries.length; i++) {
          // Split the string by " - " to get start and end times
          List<String> times = timeEntries[i].split(" - ");

          if (times.length == 2) {
            // Add the times array to the map with a dynamically generated shift key
            timing['shift${i + 1}'] = [times[0], times[1]];
          }
        }
        uploadJobProfile = {
          "userid": user?.uid,
          "schedule": "Hourly",
          "days": selectedDaysValue,
          "timing": timing,
          "services": selectedCheckBoxValue,
          "negotiable": _selectedNegoValue == 1 ? "1" : "0",
          "wage": wageBasis,
          "rate": ratecontroller.text,
        };
        isOK = true;
      }
    }
    if (isOK == true) {
      await maidDao()
          .addJobProfile(uploadJobProfile)
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
  void checkPostAvailability() async {
    String schdle = "";
    if (_selectedTimingValue == 1) {
      schdle = "Live-in";
    } else if (_selectedTimingValue == 2) {
      schdle = "Daily";
    } else {
      schdle = "Hourly";
    }
    List<Service> services = await fetchOwnServices();
    for (var serv in services) {
      if (serv.schedule == schdle) {
        print("schdle present");
        if (_selectedTimingValue == 1) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Warning"),
                  content: Text(
                      GlobalVariables.instance.xmlHandler.getString('avail')),
                );
              });
        } else if (_selectedTimingValue == 1) {
          String selTimeF = fromTimeController.text;
          String selTimeT = toTimeController.text;
          if (selTimeF.isNotEmpty && selTimeT.isNotEmpty) {
            TimeOfDay selTimeFrom = stringToTimeOfDay(selTimeF),
                selTimeTo = stringToTimeOfDay(selTimeT),
                timeF = stringToTimeOfDay(
                    serv.timing[0].toString().split(' - ')[0]),
                timet = stringToTimeOfDay(
                    serv.timing[0].toString().split(' - ')[1]);
            if (timeIsPresent(selTimeFrom, selTimeTo, timeF, timet)) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Warning"),
                      content: Text(GlobalVariables.instance.xmlHandler
                          .getString('avail')),
                    );
                  });
            }
          }
          // return const SizedBox.shrink();
          // if(serv.time_from)
        } else {
          // for hourly
          String selTimeF = fromTimeController.text;
          String selTimeT = toTimeController.text;
          if (selTimeF.isNotEmpty &&
              selTimeT.isNotEmpty &&
              selectedDaysValue.isNotEmpty) {
            for (var d in selectedDaysValue) {
              for (var servday in serv.days) {
                if (d == servday) {
                  TimeOfDay selTimeFrom = stringToTimeOfDay(selTimeF),
                      selTimeTo = stringToTimeOfDay(selTimeT),
                      timeF = stringToTimeOfDay(
                          serv.timing[0].toString().split(' - ')[0]),
                      timet = stringToTimeOfDay(
                          serv.timing[0].toString().split(' - ')[1]);
                  if (timeIsPresent(selTimeFrom, selTimeTo, timeF, timet)) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Warning"),
                            content: Text(GlobalVariables.instance.xmlHandler
                                .getString('avail')),
                          );
                        });
                    break;
                  }
                }
              }
            }
          }
          // for hourly
          // return const SizedBox.shrink();
        }
      } else {
        print("no post, OK!");
      }
    }
  }

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
        title: Text(GlobalVariables.instance.xmlHandler.getString('addjob')),
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
                                      groupValue: _selectedTimingValue,
                                      onChanged: (value) {
                                        // checkpost(value!);
                                        checkPostAvailability();
                                        setState(() {
                                          _selectedTimingValue = value!;
                                          toggleTimings(1);
                                        });
                                      }),
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
                                  Radio(
                                      value: 2,
                                      groupValue: _selectedTimingValue,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTimingValue = value!;
                                          toggleTimings(2);
                                        });
                                      }),
                                  Expanded(
                                      child: Text(GlobalVariables
                                          .instance.xmlHandler
                                          .getString('Daily')))
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Radio(
                                      value: 3,
                                      groupValue: _selectedTimingValue,
                                      onChanged: (value) {
                                        // checkpost(value!);
                                        setState(() {
                                          _selectedTimingValue = value!;
                                          toggleTimings(3);
                                        });
                                      }),
                                  Expanded(
                                      child: Text(GlobalVariables
                                          .instance.xmlHandler
                                          .getString('Hourly')))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Visibility(
                      visible:
                          showOptionsDay, // Show the options only if showOptions is true
                      child: Column(
                        children: [
                          // const Text("Day(s)", textAlign: TextAlign.center),
                          DropDownMultiSelect(
                            validator: ($selectedDaysValue) {
                              if (selectedDaysValue.isEmpty) {
                                return GlobalVariables.instance.xmlHandler
                                    .getString('selectdays');
                              } else {
                                dayValid = true;
                                return '';
                              }
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
                              checkPostAvailability();
                            },
                            whenEmpty: GlobalVariables.instance.xmlHandler
                                .getString('selectdays'),
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible:
                          showOptionsHour, // Show the options only if showOptions is true
                      child: Column(
                        children: [
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('timing'),
                              textAlign: TextAlign.center),
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
                                    maxLines: maxlinevalueshift,
                                    controller: shiftcont,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'shift',
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
                                      onPressed: () {
                                        timingcount += 1;
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Add Timing"),
                                              content: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 2.0,
                                                          horizontal: 30.0),
                                                      decoration: BoxDecoration(
                                                          color: const Color(
                                                              0xFFedf0f8),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30)),
                                                      child: TextFormField(
                                                        controller:
                                                            fromTimeController,
                                                        decoration: InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText: 'From',
                                                            hintStyle: TextStyle(
                                                                color: Color(
                                                                    0xFFb2b7bf),
                                                                fontSize:
                                                                    18.0)),
                                                        readOnly: true,
                                                        onTap: () async {
                                                          final TimeOfDay?
                                                              time =
                                                              await showTimePicker(
                                                            context: context,
                                                            initialTime:
                                                                TimeOfDay.now(),
                                                          );
                                                          if (time != null) {
                                                            setState(() {
                                                              fromTimeController
                                                                      .text =
                                                                  time.format(
                                                                      context);
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                    child: const Text(
                                                      "-",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 2.0,
                                                          horizontal: 30.0),
                                                      decoration: BoxDecoration(
                                                          color: const Color(
                                                              0xFFedf0f8),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30)),
                                                      child: TextFormField(
                                                        controller:
                                                            toTimeController,
                                                        decoration: InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText: 'To',
                                                            hintStyle: TextStyle(
                                                                color: Color(
                                                                    0xFFb2b7bf),
                                                                fontSize:
                                                                    18.0)),
                                                        readOnly: true,
                                                        onTap: () async {
                                                          final TimeOfDay?
                                                              time =
                                                              await showTimePicker(
                                                            context: context,
                                                            initialTime:
                                                                TimeOfDay.now(),
                                                          );
                                                          if (time != null) {
                                                            setState(() {
                                                              toTimeController
                                                                      .text =
                                                                  time.format(
                                                                      context);
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text("Add"),
                                                  onPressed: () {
                                                    if (fromTimeController
                                                            .text.isNotEmpty &&
                                                        toTimeController
                                                            .text.isNotEmpty) {
                                                      setState(() {
                                                        maxlinevalueshift =
                                                            maxlinevalueshift +
                                                                1;
                                                        String data =
                                                            "${fromTimeController.text} - ${toTimeController.text}";
                                                        timeEntries.add(data);
                                                        shiftcont.text =
                                                            "${shiftcont.text}$timingcount. $data\n";
                                                        fromTimeController
                                                            .clear();
                                                        toTimeController
                                                            .clear();
                                                      });
                                                      Navigator.pop(context);
                                                      setState(() {});
                                                    } else {
                                                      // Optionally, show a validation error here
                                                    }
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ))),
                            ],
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                        ],
                        // [
                        //   Text(GlobalVariables.instance.xmlHandler.getString('timing'),
                        //       textAlign: TextAlign.center),
                        //   Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //     children: [
                        //       Expanded(
                        //         child: Container(
                        //           padding: const EdgeInsets.symmetric(
                        //               vertical: 2.0, horizontal: 30.0),
                        //           decoration: BoxDecoration(
                        //               color: const Color(0xFFedf0f8),
                        //               borderRadius: BorderRadius.circular(30)),
                        //           child: TextFormField(
                        //             validator: (value) {
                        //               if (value == null || value.isEmpty) {
                        //                 return 'Please Enter Start';
                        //               } else {
                        //                 timeFromValid = true;
                        //                 return null;
                        //               }
                        //             },
                        //             controller: fromTimeController,
                        //             decoration: InputDecoration(
                        //                 border: InputBorder.none,
                        //                 hintText: GlobalVariables.instance.xmlHandler.getString('from'),
                        //                 hintStyle: TextStyle(
                        //                     color: Color(0xFFb2b7bf),
                        //                     fontSize: 18.0)),
                        //             readOnly: true,
                        //             onTap: () async {
                        //               final TimeOfDay? time =
                        //                   await showTimePicker(
                        //                 context: context,
                        //                 initialTime:
                        //                     selectedTime ?? TimeOfDay.now(),
                        //                 initialEntryMode: entryMode,
                        //                 orientation: orientation,
                        //                 builder: (BuildContext context,
                        //                     Widget? child) {
                        //                   // We just wrap these environmental changes around the
                        //                   // child in this builder so that we can apply the
                        //                   // options selected above. In regular usage, this is
                        //                   // rarely necessary, because the default values are
                        //                   // usually used as-is.
                        //                   return Theme(
                        //                     data: Theme.of(context).copyWith(
                        //                       materialTapTargetSize:
                        //                           tapTargetSize,
                        //                     ),
                        //                     // child: Directionality(
                        //                     //   textDirection: textDirection,
                        //                     child: MediaQuery(
                        //                       data: MediaQuery.of(context)
                        //                           .copyWith(
                        //                         alwaysUse24HourFormat:
                        //                             use24HourTime,
                        //                       ),
                        //                       child: child!,
                        //                     ),
                        //                     // ),
                        //                   );
                        //                 },
                        //               );
                        //               if (time != null) {
                        //                 setState(() {
                        //                   fromTimeController.text =
                        //                       time.format(context).toString();
                        //                 });
                        //                 checkPostAvailability();
                        //               }
                        //             },
                        //           ),
                        //         ),
                        //       ),
                        //       Container(
                        //         padding:
                        //             const EdgeInsets.only(left: 10, right: 10),
                        //         child: const Text(
                        //           "-",
                        //           textAlign: TextAlign.center,
                        //         ),
                        //       ),
                        //       Expanded(
                        //         child: Container(
                        //           padding: const EdgeInsets.symmetric(
                        //               vertical: 2.0, horizontal: 30.0),
                        //           decoration: BoxDecoration(
                        //               color: const Color(0xFFedf0f8),
                        //               borderRadius: BorderRadius.circular(30)),
                        //           child: TextFormField(
                        //             validator: (value) {
                        //               if (value == null || value.isEmpty) {
                        //                 return 'Please Enter End';
                        //               } else {
                        //                 timeToValid = true;
                        //                 return null;
                        //               }
                        //             },
                        //             controller: toTimeController,
                        //             decoration: InputDecoration(
                        //                 border: InputBorder.none,
                        //                 hintText: GlobalVariables.instance.xmlHandler.getString('to'),
                        //                 hintStyle: TextStyle(
                        //                     color: Color(0xFFb2b7bf),
                        //                     fontSize: 18.0)),
                        //             readOnly: true,
                        //             onTap: () async {
                        //               final TimeOfDay? time =
                        //                   await showTimePicker(
                        //                 context: context,
                        //                 initialTime:
                        //                     selectedTime ?? TimeOfDay.now(),
                        //                 initialEntryMode: entryMode,
                        //                 orientation: orientation,
                        //                 builder: (BuildContext context,
                        //                     Widget? child) {
                        //                   // We just wrap these environmental changes around the
                        //                   // child in this builder so that we can apply the
                        //                   // options selected above. In regular usage, this is
                        //                   // rarely necessary, because the default values are
                        //                   // usually used as-is.
                        //                   return Theme(
                        //                     data: Theme.of(context).copyWith(
                        //                       materialTapTargetSize:
                        //                           tapTargetSize,
                        //                     ),
                        //                     // child: Directionality(
                        //                     //   textDirection: textDirection,
                        //                     child: MediaQuery(
                        //                       data: MediaQuery.of(context)
                        //                           .copyWith(
                        //                         alwaysUse24HourFormat:
                        //                             use24HourTime,
                        //                       ),
                        //                       child: child!,
                        //                     ),
                        //                     // ),
                        //                   );
                        //                 },
                        //               );
                        //               if (time != null) {
                        //                 setState(() {
                        //                   toTimeController.text =
                        //                       time.format(context).toString();
                        //                 });
                        //                 checkPostAvailability();
                        //               }
                        //             },
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        //   const SizedBox(
                        //     height: 30.0,
                        //   ),
                        // ],
                      ),
                    ),
                    DropDownMultiSelect(
                      validator: ($selectedCheckBoxValue) {
                        if (selectedCheckBoxValue.isEmpty) {
                          return GlobalVariables.instance.xmlHandler
                              .getString('selectserv');
                        } else {
                          servicesValid = true;
                          return '';
                        }
                      },
                      decoration: InputDecoration(
                        // fillColor: Theme.of(context).colorScheme.onPrimary,
                        fillColor: Colors.amber,
                        focusColor: Theme.of(context).colorScheme.onPrimary,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.5)),
                        focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            )),
                        errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.5)),
                        focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.5)),
                      ),
                      options: variantsList,
                      selectedValues: selectedCheckBoxValue,
                      onChanged: (List<String> value) {
                        value = selectedCheckBoxValue;
                      },
                      whenEmpty: GlobalVariables.instance.xmlHandler
                          .getString('selectserv'),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Column(
                      children: [
                        Text(
                            GlobalVariables.instance.xmlHandler
                                .getString('wage'),
                            textAlign: TextAlign.center),
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
                                          groupValue: _selectedWageValue,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedWageValue = value!;
                                              //toggleWage(1);
                                            });
                                          }),
                                      Expanded(
                                        child: Text(GlobalVariables
                                            .instance.xmlHandler
                                            .getString('Weekly')),
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
                                          groupValue: _selectedWageValue,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedWageValue = value!;
                                              // toggleWage(2);
                                            });
                                          }),
                                      Expanded(
                                          child: Text(GlobalVariables
                                              .instance.xmlHandler
                                              .getString('Monthly')))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Column(
                      children: [
                        Text(
                          GlobalVariables.instance.xmlHandler.getString('rate'),
                          textAlign: TextAlign.start,
                        ),
                        Row(
                          children: [
                            Container(
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 37, 67, 133),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      topLeft: Radius.circular(30)),
                                  // shape: BoxShape.circle
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(13.0),
                                  child: Icon(
                                    rupeeSymbol,
                                    color: Colors.white,
                                  ),
                                )),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 30.0),
                                decoration: const BoxDecoration(
                                    color: Color(0xFFedf0f8),
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(30),
                                        topRight: Radius.circular(30))),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return GlobalVariables.instance.xmlHandler
                                          .getString('rate');
                                    } else {
                                      rateValid = true;
                                      return null;
                                    }
                                  },
                                  controller: ratecontroller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: GlobalVariables
                                          .instance.xmlHandler
                                          .getString('rate'),
                                      hintStyle: TextStyle(
                                          color: Color(0xFFb2b7bf),
                                          fontSize: 18.0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
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
                      height: 30.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            // email = mailcontroller.text;
                            // name = namecontroller.text;
                            // password = passwordcontroller.text;
                          });
                        }
                        toEnglish();
                        addJobProfile();
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
                                .getString('postjob'),
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
