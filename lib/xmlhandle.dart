import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart' show rootBundle;
class XMLHandler{
  Map<String,String> strings={};
  Future<void> loadStrings(String language) async{
    final xmlString=await rootBundle.loadString('assets/lang/$language.xml');
    final document=xml.XmlDocument.parse(xmlString);
    document.findAllElements('string').forEach((element){
     final key=element.getAttribute('name');
     final value=element.text;
     if(key!=null && value!=null)
     {  
        strings[key]=value;
     }
    });
  }
  String getString(String key)=>strings[key]??'';
  
}
