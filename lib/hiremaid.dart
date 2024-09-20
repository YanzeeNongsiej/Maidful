import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HireMaid extends StatefulWidget {
  final DocumentSnapshot? itemGlobal;
  final String name;
  const HireMaid({super.key, required this.itemGlobal, required this.name});
  @override
  State<HireMaid> createState() => _HireMaidState();
}

class _HireMaidState extends State<HireMaid> {
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
            const Text("Service Details", style: TextStyle(fontSize: 15))
          ],
        ),
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ExpansionTile(
                trailing: const Card(
                    color: Colors.amber,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Change",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                title: Row(
                  children: [
                    const Text("Schedule:  ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.itemGlobal?.get("schedule")),
                  ],
                ),
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
                                groupValue: 2,
                                onChanged: (value) {
                                  // // checkpost(value!);
                                  // checkPostAvailability();
                                  setState(() {
                                    //   _selectedTimingValue = value!;
                                    //   toggleTimings(1);
                                  });
                                }),
                            const Expanded(
                              child: Text('Live-in'),
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
                                groupValue: 2,
                                onChanged: (value) {
                                  setState(() {
                                    // _selectedTimingValue = value!;
                                    // toggleTimings(2);
                                  });
                                }),
                            const Expanded(child: Text('Daily'))
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Radio(
                                value: 3,
                                groupValue: 2,
                                onChanged: (value) {
                                  // checkpost(value!);
                                  setState(() {
                                    // _selectedTimingValue = value!;
                                    // toggleTimings(3);
                                  });
                                }),
                            const Expanded(child: Text('Hourly'))
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.itemGlobal?.get("schedule") == 'Hourly')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Days:  ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    for (var i = 0;
                        i < widget.itemGlobal?.get("days").length;
                        i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${i + 1}. "),
                            Expanded(
                              child:
                                  Text("${widget.itemGlobal?.get("days")[i]}"),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              if (widget.itemGlobal?.get("schedule") == 'Daily' ||
                  widget.itemGlobal?.get("schedule") == 'Hourly')
                Row(
                  children: [
                    const Text("Timing:  ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        "${widget.itemGlobal?.get("time_from")}-${widget.itemGlobal?.get("time_to")}"),
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Services:  ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var i = 0;
                      i < widget.itemGlobal?.get("services").length;
                      i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${i + 1}. "),
                          Expanded(
                            child: Text(
                                "${widget.itemGlobal?.get("services")[i]}"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Work Histroy:  ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (var i = 0;
                      i < widget.itemGlobal?.get("work_history").length;
                      i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${i + 1}. "),
                          Expanded(
                            child: Text(
                                "${widget.itemGlobal?.get("work_history")[i]}"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Text("Wage:  ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(widget.itemGlobal?.get("wage"),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Rate:  ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
                      Text("\u{20B9}${widget.itemGlobal?.get("rate")}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
