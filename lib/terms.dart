import 'package:flutter/material.dart';
import 'package:ibitf_app/employerhome.dart';
import 'package:ibitf_app/singleton.dart';
import 'package:styled_text/styled_text.dart';

class Terms extends StatefulWidget {
  int when = 1;
  String? uname;
  String? uid;
  Terms({super.key, when, this.uname, this.uid});

  @override
  State<Terms> createState() => _MyTerms();
}

class _MyTerms extends State<Terms> {
  String content = "";
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    GlobalVariables.instance.selected == 'English'
        ? content =
            '<bold>Welcome to MaidFul!</bold> \n This app is designed to help connect employers with household workers, such as maids. By using this app, you agree to the following terms and conditions:\n\n<bold>Purpose of the App</bold>\nMaidFul provides a platform for connecting household workers (maids) with potential employers. However, we are not responsible for any direct hiring processes, employment agreements, or the conduct of either party beyond the terms outlined here.\n\n<bold>Respectful Communication</bold>\nMaidFul includes a chat feature to facilitate communication between users. All communication should remain respectful and professional. Foul language, harassment, or any form of abusive language is strictly prohibited. Users engaging in inappropriate behavior may be banned from the platform without prior warning.\n\n<bold>Non-Liability in Disputes</bold>\nMaidFul does not mediate or involve itself in disputes between users. Any disagreements or conflicts that arise must be resolved independently between the users. We are not legally responsible for any issues, including misunderstandings, financial disagreements, or unsatisfactory work performance.\n\n<bold>Privacy and Data Usage</bold>\nPlease be mindful of the information you share through the chat system. Although we prioritize user privacy and are committed to securing your data, we advise against sharing sensitive personal information on this platform.\n\n<bold>Hiring Agreements</bold>\nAny agreements regarding employment or services made between users are independent of MaidFul. We are not responsible for the terms, conditions, or fulfillment of any employment or service agreements made between users.\n\n<bold>Disclaimer of Warranties</bold>\nMaidFul provides the app "as is" without guarantees regarding performance, reliability, or the accuracy of information. We do not verify the identity or background of users, and we encourage users to exercise caution and conduct their own due diligence.\n\n<bold>Termination of Access</bold>\nMaidFul reserves the right to suspend or terminate any user’s access to the platform if they violate these terms or engage in illegal or unethical activities.\n\n<bold>Updates to Terms</bold>\nThese terms may be updated periodically to reflect changes in policies or app features. Users are encouraged to review the terms periodically to stay informed.\n\nThank you for being a part of the MaidFul community!\n<bold>By using our app, you agree to these terms and aim to uphold a respectful and constructive platform for all.</bold>'
        : content =
            '<bold>Ngi pdiang sngewbha ia phi sha ka MaidFul!</bold>\nIa kane ka app la shna khnang ban iarap ban pyniasoh ia ki nongpyntreikam bad ki nongtrei kam iing. Da kaba pyndonkam ia kane ka app, phi mynjur ia kine ki kyndon harum:\n\n<bold>Ka jingthmu jong ka App. </bold>\nKa MaidFul ka ai ka lad ban pyniasoh ia ki nongtrei kam iing bad ki nongpyntreikam kiba lah ban wan. Hynrei, ngim don jingkitkhlieh na ka bynta kino kino ki rukom thung kam ba beit, ki jingiateh kam, lane ka jingleh jong kano kano ka liang palat ia ki kyndon ba la kdew hangne.\n\n<bold>Ka jingiakren kaba don burom</bold>\nKa MaidFul ka kynthup ia ka chat ban pynsuk ia ka jingiakren hapdeng ki nongpyndonkam. Baroh ki jingiakren ki dei ban long kiba don burom bad kiba biang. La khang pyrshah jur ia ka jingkren bein, jingpynshitom bein, lane kano kano ka rukom kren bein. Ki nongpyndonkam kiba leh ïa ki kam bym dei ki lah ban shah khang na ka platform khlem da ai jingmaham lypa.\n\n<bold>Ka jingbym kitkhlieh ha ki jingiakajia</bold>\nKa MaidFul kam ju pynïasuk ne pynïasoh ïalade ha ki jingïakynad hapdeng ki nongpyndonkam. Kino kino ki jingbym iasngewthuh jingmut ne jingialeh kiba mih dei ban pynbeit marwei marwei hapdeng ki nongpyndonkam. Ngim don jingkitkhlieh katkum ka ain na ka bynta kino kino ki jingeh, kynthup ia ka jingbym iasngewthuh jingmut, ha ka liang ka pisa tyngka, lane ka jingtreikam kaba khlem pynhun.\n\n<bold>Ka jingpyndonkam ia ki data</bold>\nSngewbha buh jingmut ia ki jingtip kiba phi iasam lyngba ka chat system. Watla ngi buh hakhmat eh ïa ka jinglong kyrpang jong ki nongpyndonkam bad ngi aiti ban pynïada ïa ki jingtip jong phi, ngi ai jingmut ban ym sam ïa ki jingtip ba kongsan ha kane ka platform.\n\n</bold>Ki jingiateh thung kam</bold>\nKino kino ki jingiateh ha kaba iadei bad ka kam ne ki jingshakri ba la leh hapdeng ki nongpyndonkam ki long kiba laitluid na ka MaidFul. Ngim don jingkitkhlieh na ka bynta ki kyndon, ki jingpynbeit, ne ka jingpyndep ïa kino kino ki jingïateh kular treikam ne jingshakri ba la leh hapdeng ki nongpyndonkam.\n\n<bold>Ka jingpynpaw ia ki jingkular</bold>\nKa MaidFul ka ai ia ka app "kumba ka long" khlem jingkular ha kaba iadei bad ka jingtreikam, ka jingshaniah, lane ka jinglong thikna jong ki jingtip. Ngim pynshisha ia ka jinglong ne ka tynrai jong ki nongpyndonkam, bad ngi pynshlur ia ki nongpyndonkam ban long kiba husiar bad ban pynlong ia la ka jong ka jingpeit bniah.\n\n<bold>Ka jingpynkut noh ia ka jingrung</bold>\nKa MaidFul ka don ka hok ban pynsangeh ne pynkut noh ïa ka jingrung jong kino kino ki nongpyndonkam sha ka platform lada ki pynkheiñ ïa kine ki kyndon ne ki leh ïa ki kam be-aiñ ne ki kam bym hok.\n\n<bold>Ki jingpynkylla ia ki kyndon</bold>\nIa kine ki kyndon lah ban pynthymmai man ka por ban pyni ia ki jingkylla ha ki policy lane ki jingdonkam jong ka app. La kyntu ia ki nongpyndonkam ban peit bniah ia ki kyndon man ka por khnang ban tip.\n\nKhublei shibun ba phi la long shi bynta jong ka imlang sahlang jong ka MaidFul!\n<bold>Da kaba pyndonkam ïa ka app jong ngi, phi mynjur ïa kine ki kyndon bad thmu ban pynneh ïa ka rynsan kaba don burom bad kaba tei na ka bynta baroh.</bold>';

    GlobalVariables.instance.xmlHandler
        .loadStrings(GlobalVariables.instance.selected)
        .then((onValue) {
      setState(() {});
    });
  }

  void _onAgreePressed() {
    if (!isChecked) {
      // Show Snackbar if not agreed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You must accept the terms and conditions before proceeding.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EmployerHome(
                    uname: widget.uname,
                    uid: widget.uid,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 8,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.shade100, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description,
                            color: Colors.blueAccent, size: 30),
                        const SizedBox(width: 8),
                        Text(
                          'Terms and Conditions',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.blueAccent.withOpacity(0.5),
                      thickness: 1.5,
                    ),
                    const SizedBox(height: 10),
                    StyledText(
                      text: content,
                      tags: {
                        'bold': StyledTextTag(
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: widget.when == 1 ? true : false,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Center(
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  GlobalVariables.instance.xmlHandler
                                      .getString('read'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: _onAgreePressed,
                              child: Text(
                                GlobalVariables.instance.xmlHandler
                                    .getString('agree'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
