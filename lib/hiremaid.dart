import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ibitf_app/DAO/maiddao.dart';
import 'package:multiselect/multiselect.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:ibitf_app/changelang.dart';
import 'package:ibitf_app/controller/chat_controller.dart';

class HireMaid extends StatefulWidget {
  final DocumentSnapshot? itemGlobal;
  final String name;
  const HireMaid({super.key, required this.itemGlobal, required this.name});
  @override
  State<HireMaid> createState() => _HireMaidState();
}

class _HireMaidState extends State<HireMaid> {
  final ChatController chatcontroller = ChatController();
  List<String> origselectedDaysValue = [];
  List<String> origselectedCheckBoxValue = [];
  List<String> selectedCheckBoxValue = [];
  List<String> selectedDaysValue = [];
  Map<String, String> all = {};
  final ratecontroller = TextEditingController();
  static const IconData rupeeSymbol =
      IconData(0x20B9, fontFamily: 'MaterialIcons');
  bool dayValid = false,
      timeFromValid = false,
      timeToValid = false,
      servicesValid = false,
      rateValid = false;

  List<String> daysList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  List<String> variantsList = [
    "Housekeeping",
    "Cooking",
    "Laundry",
    "Babysitting",
    "Elderly Care",
    "Grocery Shopping",
  ];

  final fromTimeController = TextEditingController();
  final toTimeController = TextEditingController();
  Orientation? orientation;
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  bool use24HourTime = false;
  int _selectedWageValue = 1;
  late int selectedScheduleValue = -1;
  late String selectedScheduleString = "",
      defTimeFrom = "",
      defTimeTo = "",
      _selectedWageString = "",
      defRate = "";
  TimeOfDay? selectedTime;
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  bool showOptionsDay = false, showOptionsHour = false;

  @override
  void initState() {
    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((a) {
      if (widget.itemGlobal?.get("schedule") == "Live-in") {
        selectedScheduleValue = 1;
        selectedScheduleString =
            GlobalVariables.instance.xmlHandler.getString('livein');
      } else if (widget.itemGlobal?.get("schedule") == "Daily") {
        selectedScheduleValue = 2;
        selectedScheduleString =
            GlobalVariables.instance.xmlHandler.getString('daily');
        showOptionsHour = true;
      } else {
        selectedScheduleValue = 3;
        selectedScheduleString =
            GlobalVariables.instance.xmlHandler.getString('hourly');
        showOptionsHour = true;
        showOptionsDay = true;
      }
      if (widget.itemGlobal?.get("wage") == "Weekly") {
        _selectedWageValue = 1;
        _selectedWageString =
            GlobalVariables.instance.xmlHandler.getString('weekly');
      } else {
        _selectedWageValue = 2;
        _selectedWageString =
            GlobalVariables.instance.xmlHandler.getString('monthly');
      }
      defTimeFrom = widget.itemGlobal?.get("time_from");
      defTimeTo = widget.itemGlobal?.get("time_to");
      defRate = widget.itemGlobal?.get("rate");
      origselectedDaysValue = widget.itemGlobal?.get("days").cast<String>();
      origselectedCheckBoxValue =
          widget.itemGlobal?.get("services").cast<String>();

      daysList[0] = GlobalVariables.instance.xmlHandler.getString('Monday');
      daysList[1] = GlobalVariables.instance.xmlHandler.getString('Tuesday');
      daysList[2] = GlobalVariables.instance.xmlHandler.getString('Wednesday');
      daysList[3] = GlobalVariables.instance.xmlHandler.getString('Thursday');
      daysList[4] = GlobalVariables.instance.xmlHandler.getString('Friday');
      daysList[5] = GlobalVariables.instance.xmlHandler.getString('Saturday');
      daysList[6] = GlobalVariables.instance.xmlHandler.getString('Sunday');

      variantsList[0] =
          GlobalVariables.instance.xmlHandler.getString('Housekeeping');
      variantsList[1] =
          GlobalVariables.instance.xmlHandler.getString('Cooking');
      variantsList[2] =
          GlobalVariables.instance.xmlHandler.getString('Laundry');
      variantsList[3] =
          GlobalVariables.instance.xmlHandler.getString('Babysitting');
      variantsList[4] =
          GlobalVariables.instance.xmlHandler.getString('Elderly Care');
      variantsList[5] =
          GlobalVariables.instance.xmlHandler.getString('Grocery Shopping');
      selectedDaysValue = processLang(
          origselectedDaysValue, GlobalVariables.instance.xmlHandler);
      selectedCheckBoxValue = processLang(
          origselectedCheckBoxValue, GlobalVariables.instance.xmlHandler);

      print(daysList);
      setState(() {});
    });
    super.initState();

    print(GlobalVariables.instance.xmlHandler.getString('hourly'));

    //  as List<String>;
    // List<String> strlist = dynamiclist.cast<String>();

    // super.initState();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name),
            Text(GlobalVariables.instance.xmlHandler.getString('servdetails'),
                style: const TextStyle(fontSize: 15))
          ],
        ),
      ),
      body: Card(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text.rich(TextSpan(text: '* Click ', children: <InlineSpan>[
                  TextSpan(
                    text:
                        GlobalVariables.instance.xmlHandler.getString('change'),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                  ),
                  TextSpan(
                    text:
                        GlobalVariables.instance.xmlHandler.getString('click'),
                  )
                ])),
                ExpansionTile(
                  title: Row(
                    children: [
                      Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('sched'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(selectedScheduleString),
                    ],
                  ),
                  trailing: Card(
                      color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('change'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Radio(
                                  value: 1,
                                  groupValue: selectedScheduleValue,
                                  onChanged: (value) {
                                    // // checkpost(value!);
                                    // checkPostAvailability();
                                    setState(() {
                                      selectedScheduleValue = value!;
                                      selectedScheduleString = GlobalVariables
                                          .instance.xmlHandler
                                          .getString('livein');
                                      toggleTimings(1);
                                    });
                                  }),
                              Expanded(
                                child: Text(GlobalVariables.instance.xmlHandler
                                    .getString('livein')),
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
                                  groupValue: selectedScheduleValue,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedScheduleValue = value!;
                                      selectedScheduleString = GlobalVariables
                                          .instance.xmlHandler
                                          .getString('daily');
                                      toggleTimings(2);
                                    });
                                  }),
                              Expanded(
                                  child: Text(GlobalVariables
                                      .instance.xmlHandler
                                      .getString('daily')))
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Radio(
                                  value: 3,
                                  groupValue: selectedScheduleValue,
                                  onChanged: (value) {
                                    // checkpost(value!);
                                    setState(() {
                                      selectedScheduleValue = value!;
                                      selectedScheduleString = "Hourly";
                                      toggleTimings(3);
                                    });
                                  }),
                              Expanded(
                                  child: Text(GlobalVariables
                                      .instance.xmlHandler
                                      .getString('hourly')))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // if (widget.itemGlobal?.get("schedule") == 'Hourly')
                Visibility(
                  visible: showOptionsDay,
                  child: ExpansionTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('day'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          for (var i = 0; i < selectedDaysValue.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${i + 1}. "),
                                  Expanded(
                                    child: Text(selectedDaysValue[i]),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: Card(
                          color: Colors.amber,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('change'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          )),
                      children: <Widget>[
                        Column(
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
                                selectedDaysValue = value;
                                setState(() {});
                                // checkPostAvailability();
                              },
                              whenEmpty: 'Select Working Days',
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                          ],
                        ),
                      ]),
                ),
                // if (widget.itemGlobal?.get("schedule") == 'Daily' ||
                //     widget.itemGlobal?.get("schedule") == 'Hourly')
                Visibility(
                  visible: showOptionsHour,
                  child: ExpansionTile(
                      title: Row(
                        children: [
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('timing'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text("$defTimeFrom-$defTimeTo"),
                        ],
                      ),
                      trailing: Card(
                          color: Colors.amber,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('change'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          )),
                      children: <Widget>[
                        Column(
                          children: [
                            Text(
                                GlobalVariables.instance.xmlHandler
                                    .getString('timing'),
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
                                        borderRadius:
                                            BorderRadius.circular(30)),
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
                                            defTimeFrom =
                                                time.format(context).toString();
                                          });
                                          // checkPostAvailability();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
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
                                        borderRadius:
                                            BorderRadius.circular(30)),
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
                                            defTimeTo =
                                                time.format(context).toString();
                                          });
                                          // checkPostAvailability();
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
                      ]),
                ),
                ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          GlobalVariables.instance.xmlHandler.getString('serv'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      for (var i = 0; i < selectedCheckBoxValue.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${i + 1}. "),
                              Expanded(
                                child: Text(selectedCheckBoxValue[i]),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: Card(
                      color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('change'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  children: [
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
                        // value = selectedCheckBoxValue;
                        selectedCheckBoxValue = value;
                        setState(() {});
                      },
                      whenEmpty: 'Select Service(s)',
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                  ],
                ),
                // Work History
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Text("Work Histroy:  ",
                //         style: TextStyle(fontWeight: FontWeight.bold)),
                //     for (var i = 0;
                //         i < widget.itemGlobal?.get("work_history").length;
                //         i++)
                //       Padding(
                //         padding: const EdgeInsets.only(left: 30),
                //         child: Row(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text("${i + 1}. "),
                //             Expanded(
                //               child: Text(
                //                   "${widget.itemGlobal?.get("work_history")[i]}"),
                //             ),
                //           ],
                //         ),
                //       ),
                //   ],
                // ),

                ExpansionTile(
                  title: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                              GlobalVariables.instance.xmlHandler
                                  .getString('wage'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(_selectedWageString,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                  trailing: Card(
                      color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('change'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  children: [
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
                                              _selectedWageString =
                                                  GlobalVariables
                                                      .instance.xmlHandler
                                                      .getString('weekly');
                                              //toggleWage(1);
                                            });
                                          }),
                                      Expanded(
                                        child: Text(GlobalVariables
                                            .instance.xmlHandler
                                            .getString('weekly')),
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
                                              _selectedWageString =
                                                  GlobalVariables
                                                      .instance.xmlHandler
                                                      .getString('monthly');
                                              // toggleWage(2);
                                            });
                                          }),
                                      Expanded(
                                          child: Text(GlobalVariables
                                              .instance.xmlHandler
                                              .getString('monthly')))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Row(
                    children: [
                      Text(
                          GlobalVariables.instance.xmlHandler.getString('rate'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
                      Text("\u{20B9}$defRate",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
                    ],
                  ),
                  trailing: Card(
                      color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          GlobalVariables.instance.xmlHandler
                              .getString('change'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  children: [
                    Column(
                      children: [
                        // const Text(
                        //   "Rate",
                        //   textAlign: TextAlign.start,
                        // ),
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
                                  onChanged: (value) =>
                                      {defRate = value, setState(() {})},
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40.0,
                ),

                Container(
                    decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: TextButton(
                      onPressed: sendAck,
                      child: Text(
                        GlobalVariables.instance.xmlHandler
                            .getString('sendack'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
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

  sendAck() async {
    final User? user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> uploadAck = {};
    bool isOK = false;
    await toEnglish();
    if (selectedScheduleValue == 1) {
      uploadAck = {
        "userid": user?.uid,
        "receiver": widget.itemGlobal?.get("userid"),
        "schedule": "Live-in",
        "days": daysList,
        "time_from": "12:00 AM",
        "time_to": "11:59 PM",
        "services": selectedCheckBoxValue,
        "wage": _selectedWageValue,
        "rate": defRate,
        "status": 1,
      };
      isOK = true;
    } else if (selectedScheduleValue == 2) {
      uploadAck = {
        "userid": user?.uid,
        "receiver": widget.itemGlobal?.get("userid"),
        "schedule": "Daily",
        "days": daysList,
        "time_from": fromTimeController.text,
        "time_to": toTimeController.text,
        "services": selectedCheckBoxValue,
        "wage": _selectedWageValue,
        "rate": defRate,
        "status": 1,
      };
      isOK = true;
    } else {
      uploadAck = {
        "userid": user?.uid,
        "receiver": widget.itemGlobal?.get("userid"),
        "schedule": "Hourly",
        "days": selectedDaysValue,
        "time_from": fromTimeController.text,
        "time_to": toTimeController.text,
        "services": selectedCheckBoxValue,
        "wage": _selectedWageValue,
        "rate": defRate,
        "status": 1,
      };
      isOK = true;
    }

    if (isOK == true) {
      String ackid;
      ackid = await maidDao()
          .addAck(uploadAck)
          .whenComplete(
              () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    GlobalVariables.instance.xmlHandler.getString('addedsucc'),
                    style: const TextStyle(fontSize: 20.0),
                  ))))
          .whenComplete(() => Navigator.pop(context));
      print(ackid);
      await chatcontroller.sendMessage(widget.itemGlobal?.get("userid"), "ack",
          ackid, "services", widget.itemGlobal?.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        GlobalVariables.instance.xmlHandler.getString('error'),
        style: const TextStyle(fontSize: 20.0),
      )));
    }
    List<String> res =
        await english(selectedDaysValue, GlobalVariables.instance.selected);
    print("Converted days: $res");
    List<String> res2 =
        await english(selectedCheckBoxValue, GlobalVariables.instance.selected);
    print("Converted services: $res2");
  }
}
