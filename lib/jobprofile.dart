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

class JobProfile extends StatefulWidget {
  const JobProfile({Key? key}) : super(key: key);

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
  static const IconData rupeeSymbol =
      IconData(0x20B9, fontFamily: 'MaterialIcons');
  bool dayValid = false,
      timeFromValid = false,
      timeToValid = false,
      servicesValid = false,
      rateValid = false;
  int whcount = 0, maxlinevalue = 1;
  int _selectedTimingValue = 1;
  int _selectedWageValue = 1;
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
  final XMLHandler _xmlHandler = XMLHandler();
  GlobalVariables gv = GlobalVariables();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _xmlHandler.loadStrings(gv.selected);
  }

  addJobProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    bool isOK = false;
    String wageBasis;
    if (_selectedWageValue == 1) {
      wageBasis = "Weekly";
    } else {
      wageBasis = "Monthly";
    }
    Map<String, dynamic> uploadJobProfile = {};
    if (_selectedTimingValue == 1) {
      if (servicesValid && rateValid) {
        uploadJobProfile = {
          "userid": user?.uid,
          "schedule": "Live-in",
          "days": daysList,
          "time_from": "12:00 AM",
          "time_to": "11:59 PM",
          "services": selectedCheckBoxValue,
          "wage": wageBasis,
          "rate": ratecontroller.text,
        };
        isOK = true;
      }
    } else if (_selectedTimingValue == 2) {
      if (timeFromValid && timeToValid && servicesValid && rateValid) {
        uploadJobProfile = {
          "userid": user?.uid,
          "schedule": "Daily",
          "days": daysList,
          "time_from": fromTimeController.text,
          "time_to": toTimeController.text,
          "services": selectedCheckBoxValue,
          "wage": wageBasis,
          "rate": ratecontroller.text,
        };
        isOK = true;
      }
    } else {
      if (timeFromValid &&
          timeToValid &&
          servicesValid &&
          dayValid &&
          rateValid) {
        uploadJobProfile = {
          "userid": user?.uid,
          "schedule": "Hourly",
          "days": selectedDaysValue,
          "time_from": fromTimeController.text,
          "time_to": toTimeController.text,
          "services": selectedCheckBoxValue,
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
                    _xmlHandler.getString('addedsucc'),
                    style: TextStyle(fontSize: 20.0),
                  ))))
          .whenComplete(() => Navigator.pop(context));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        _xmlHandler.getString('error'),
        style: TextStyle(fontSize: 20.0),
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
                  title: Text("Warning"),
                  content: Text(_xmlHandler.getString('avail')),
                );
              });
        } else if (_selectedTimingValue == 1) {
          String selTimeF = fromTimeController.text;
          String selTimeT = toTimeController.text;
          if (selTimeF.isNotEmpty && selTimeT.isNotEmpty) {
            TimeOfDay selTimeFrom = stringToTimeOfDay(selTimeF),
                selTimeTo = stringToTimeOfDay(selTimeT),
                timeF = stringToTimeOfDay(serv.time_from),
                timet = stringToTimeOfDay(serv.time_to);
            if (timeIsPresent(selTimeFrom, selTimeTo, timeF, timet)) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Warning"),
                      content: Text(_xmlHandler.getString('avail')),
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
                      timeF = stringToTimeOfDay(serv.time_from),
                      timet = stringToTimeOfDay(serv.time_to);
                  if (timeIsPresent(selTimeFrom, selTimeTo, timeF, timet)) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Warning"),
                            content: Text(_xmlHandler.getString('avail')),
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
        title: Text(_xmlHandler.getString('addjob')),
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
                                    child:
                                        Text(_xmlHandler.getString('livein')),
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
                                      child:
                                          Text(_xmlHandler.getString('daily')))
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
                                      child:
                                          Text(_xmlHandler.getString('hourly')))
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
                                return 'Please Select Working Days';
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
                            whenEmpty: 'Select Working Days',
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
                          Text(_xmlHandler.getString('timing'),
                              textAlign: TextAlign.center),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 30.0),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFedf0f8),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Start';
                                      } else {
                                        timeFromValid = true;
                                        return null;
                                      }
                                    },
                                    controller: fromTimeController,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "From",
                                        hintStyle: TextStyle(
                                            color: Color(0xFFb2b7bf),
                                            fontSize: 18.0)),
                                    readOnly: true,
                                    onTap: () async {
                                      final TimeOfDay? time =
                                          await showTimePicker(
                                        context: context,
                                        initialTime:
                                            selectedTime ?? TimeOfDay.now(),
                                        initialEntryMode: entryMode,
                                        orientation: orientation,
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          // We just wrap these environmental changes around the
                                          // child in this builder so that we can apply the
                                          // options selected above. In regular usage, this is
                                          // rarely necessary, because the default values are
                                          // usually used as-is.
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              materialTapTargetSize:
                                                  tapTargetSize,
                                            ),
                                            // child: Directionality(
                                            //   textDirection: textDirection,
                                            child: MediaQuery(
                                              data: MediaQuery.of(context)
                                                  .copyWith(
                                                alwaysUse24HourFormat:
                                                    use24HourTime,
                                              ),
                                              child: child!,
                                            ),
                                            // ),
                                          );
                                        },
                                      );
                                      if (time != null) {
                                        setState(() {
                                          fromTimeController.text =
                                              time.format(context).toString();
                                        });
                                        checkPostAvailability();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: const Text(
                                  "-",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 30.0),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFedf0f8),
                                      borderRadius: BorderRadius.circular(30)),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter End';
                                      } else {
                                        timeToValid = true;
                                        return null;
                                      }
                                    },
                                    controller: toTimeController,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "To",
                                        hintStyle: TextStyle(
                                            color: Color(0xFFb2b7bf),
                                            fontSize: 18.0)),
                                    readOnly: true,
                                    onTap: () async {
                                      final TimeOfDay? time =
                                          await showTimePicker(
                                        context: context,
                                        initialTime:
                                            selectedTime ?? TimeOfDay.now(),
                                        initialEntryMode: entryMode,
                                        orientation: orientation,
                                        builder: (BuildContext context,
                                            Widget? child) {
                                          // We just wrap these environmental changes around the
                                          // child in this builder so that we can apply the
                                          // options selected above. In regular usage, this is
                                          // rarely necessary, because the default values are
                                          // usually used as-is.
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              materialTapTargetSize:
                                                  tapTargetSize,
                                            ),
                                            // child: Directionality(
                                            //   textDirection: textDirection,
                                            child: MediaQuery(
                                              data: MediaQuery.of(context)
                                                  .copyWith(
                                                alwaysUse24HourFormat:
                                                    use24HourTime,
                                              ),
                                              child: child!,
                                            ),
                                            // ),
                                          );
                                        },
                                      );
                                      if (time != null) {
                                        setState(() {
                                          toTimeController.text =
                                              time.format(context).toString();
                                        });
                                        checkPostAvailability();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                        ],
                      ),
                    ),
                    DropDownMultiSelect(
                      validator: ($selectedCheckBoxValue) {
                        if (selectedCheckBoxValue.isEmpty) {
                          return 'Please Select Service(s)';
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
                      whenEmpty: 'Select Service(s)',
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Column(
                      children: [
                        Text(_xmlHandler.getString('wage'),
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
                                        child: Text(
                                            _xmlHandler.getString('weekly')),
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
                                          child: Text(
                                              _xmlHandler.getString('monthly')))
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
                          _xmlHandler.getString('rate'),
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
                                      return 'Please Enter Rate';
                                    } else {
                                      rateValid = true;
                                      return null;
                                    }
                                  },
                                  controller: ratecontroller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Rate",
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
                    GestureDetector(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            // email = mailcontroller.text;
                            // name = namecontroller.text;
                            // password = passwordcontroller.text;
                          });
                        }
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
                            _xmlHandler.getString('postjob'),
                            style: TextStyle(
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
