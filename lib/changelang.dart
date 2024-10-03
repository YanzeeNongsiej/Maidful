import 'package:ibitf_app/xmlhandle.dart';

List<String> processLang(List<String> s, XMLHandler xml) {
  List<String> result = [];

  for (var val in s) {
    result.add(xml.getString(val));
  }
  return result;
}
