import 'package:flutter/material.dart';
import 'package:ibitf_app/xmlhandle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalVariables extends ChangeNotifier {
  static final GlobalVariables instance = GlobalVariables._();
  factory GlobalVariables() => instance;
  GlobalVariables._();
  XMLHandler xmlHandler = XMLHandler();
  String sel = "English";
  String get selected => sel;
  SharedPreferences? prefs;

  set selected(String val) {
    sel = val;
    xmlHandler.loadStrings(sel).then((a) {});
    notifyListeners();
  }

  String uname = "";
  String get username => uname;
  set username(String u) {
    uname = u;
  }

  bool hasnew = false;
  bool get hasnewmsg => hasnew;
  set hasnewmsg(bool h) {
    hasnew = h;
    _saveHasNewMsg(h).then((a) {
      notifyListeners();
    });
  }

  // Save hasnewmsg to SharedPreferences
  Future<void> _saveHasNewMsg(bool value) async {
    prefs = await SharedPreferences.getInstance();
    print("Saving value: $value");
    if (prefs != null) {
      await prefs!.setBool('hasnewmsg', value);
      print("Saved prefs as ${prefs!.getBool('hasnewmsg')}");
    } else {
      print("SharedPreferences not initialized");
    }
  }

// Load hasnewmsg from SharedPreferences
  Future<void> loadHasNewMsg() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      print('Loaded pref as ${prefs!.getBool('hasnewmsg')}');
      hasnew = prefs!.getBool('hasnewmsg') ?? false;
      print("hasnew value: $hasnew");
    } else {
      print("SharedPreferences not initialized");
    }
    notifyListeners();
  }

  int urole = -1;
  int get userrole => urole;
  set userrole(int r) {
    urole = r;
    notifyListeners();
  }
}
