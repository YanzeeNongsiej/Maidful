import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ibitf_app/singleton.dart';

class ServicePricingInsights extends StatefulWidget {
  @override
  _ServicePricingInsightsState createState() => _ServicePricingInsightsState();
}

class _ServicePricingInsightsState extends State<ServicePricingInsights> {
  String? selectedService;
  String selectedRateType = 'per hour';
  List<int> prices = [];

  final rateTypes = ['per hour', 'per day', 'per month'];
  final Map<String, List<int>> clusteredPrices = {};
  List<String> serviceNames = [];

  @override
  void initState() {
    super.initState();
    loadServiceNames();
  }

  Map<String, String> displayToKey = {}; // Add this to your state

  Future<void> loadServiceNames() async {
    final isKhasi = GlobalVariables.instance.selected == 'Khasi';
    final langField = isKhasi ? 'Khasi' : 'English';

    final snapshot =
        await FirebaseFirestore.instance.collection('skills').get();

    final names = <String>[];
    final map = <String, String>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final english = data['English']?.toString() ?? '';
      final khasi = data['Khasi']?.toString() ?? '';
      final display = isKhasi ? khasi : english;

      if (display.isNotEmpty && english.isNotEmpty) {
        names.add(display);
        map[display] = english; // always map display name back to English
      }
    }

    setState(() {
      serviceNames = names;
      displayToKey = map;
      if (serviceNames.isNotEmpty) {
        selectedService = serviceNames.first;
        loadPrices();
      }
    });
  }

  Future<void> loadPrices() async {
    final englishKey = displayToKey[selectedService];
    if (englishKey == null) return;

    final snapshot =
        await FirebaseFirestore.instance.collection('services').get();

    List<int> extractedPrices = [];

    for (var doc in snapshot.docs) {
      final servicesMap = doc.data()['services'] as Map<String, dynamic>?;

      if (servicesMap != null && servicesMap[englishKey] != null) {
        final data = servicesMap[englishKey] as List<dynamic>;
        final rate = data.last.toString();
        final priceList = data
            .sublist(0, data.length - 1)
            .map((e) => int.tryParse(e.toString()) ?? 0)
            .toList();

        if (rate == selectedRateType) {
          extractedPrices.addAll(priceList);
        }
      }
    }

    setState(() {
      prices = extractedPrices;
    });
  }

  Widget buildChart() {
    if (prices.isEmpty) {
      return Text("No pricing data found for this selection.");
    }

    // Step 1: Bucket prices into ranges
    final buckets = <String, int>{};
    final step = 100;

    for (var price in prices) {
      int lower = (price ~/ step) * step;
      int upper = lower + step;
      String rangeLabel = "$lower–$upper";
      buckets[rangeLabel] = (buckets[rangeLabel] ?? 0) + 1;
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.brown,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final entries = buckets.entries.toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  final total = prices.length;
                  final percentage = (entry.value / total) * 100;
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: "${percentage.toStringAsFixed(1)}%",
                    color: colors[index % colors.length],
                    radius: 60,
                    titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
              "📊 ${GlobalVariables.instance.xmlHandler.getString('pricedist')}",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            return Row(
              children: [
                Container(
                    width: 14,
                    height: 14,
                    color: colors[index % colors.length]),
                SizedBox(width: 8),
                Text(
                  "₹${entry.key}: ${entry.value} ${GlobalVariables.instance.xmlHandler.getString('maiden2')}",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget buildDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "1. ${GlobalVariables.instance.xmlHandler.getString('selserv')}",
          style: TextStyle(color: Colors.white),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedService,
          items: serviceNames
              .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: TextStyle(color: Colors.black),
                  )))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedService = val;
            });
            loadPrices();
          },
        ),
        SizedBox(height: 10),
        Text(
          "2. ${GlobalVariables.instance.xmlHandler.getString('chooseview')}",
          style: TextStyle(color: Colors.white),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedRateType,
          items: rateTypes
              .map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(
                    GlobalVariables.instance.xmlHandler
                        .getString(r.replaceAll(' ', '')),
                    style: TextStyle(color: Colors.black),
                  )))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedRateType = val!;
            });
            loadPrices();
          },
        ),
      ],
    );
  }

  Widget buildExplanation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "💡 ${GlobalVariables.instance.xmlHandler.getString('thischart')} '${selectedService ?? ''}' ${GlobalVariables.instance.xmlHandler.getString('charged')} '${GlobalVariables.instance.xmlHandler.getString(selectedRateType.replaceAll(' ', ''))}'. "
        "${GlobalVariables.instance.xmlHandler.getString('eachbar')}",
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            Text(GlobalVariables.instance.xmlHandler.getString('transpricing')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade100, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GlassmorphicContainer(
                  child: buildDropdowns(),
                ),
                SizedBox(height: 16),
                GlassmorphicContainer(
                  child: buildExplanation(),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GlassmorphicContainer(
                    child: buildChart(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;

  const GlassmorphicContainer({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
