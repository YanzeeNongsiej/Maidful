class GlobalVariables {
  static final GlobalVariables instance = GlobalVariables._();
  factory GlobalVariables() => instance;
  GlobalVariables._();
  String sel = "English";
  String get selected => sel;
  set selected(String val) {
    sel = val;
  }

  String uname = "";
  String get username => uname;
  set username(String u) {
    uname = u;
  }
}
