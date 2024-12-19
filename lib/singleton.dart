import 'package:flutter/material.dart';
import 'package:ibitf_app/xmlhandle.dart';

class GlobalVariables extends ChangeNotifier {
  static final GlobalVariables instance = GlobalVariables._();
  factory GlobalVariables() => instance;
  GlobalVariables._();
  XMLHandler xmlHandler = XMLHandler();
  String sel = "English";
  String get selected => sel;
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

  int urole = -1;
  int get userrole => urole;
  set userrole(int r) {
    urole = r;
  }
}
