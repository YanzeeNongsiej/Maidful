import 'package:ibitf_app/xmlhandle.dart';
import 'package:ibitf_app/singleton.dart';

List<String> processLang(List<String> s, XMLHandler xml) {
  List<String> result = [];

  for (var val in s) {
    result.add(xml.getString(val));
  }
  return result;
}

Future<List<String>> english(List<String> s, String selected) async {
  List<String> result = [];
  String lang;
  if (selected == "Khasi") {
    lang = "Khasi";
  } else {
    lang = "English";
  }
  GlobalVariables.instance.xmlHandler.loadStrings(lang).then((val) {
    for (var i in s) {
      result.add(GlobalVariables.instance.xmlHandler.getEnglishString(i));
    }
  });
  return result;
}
