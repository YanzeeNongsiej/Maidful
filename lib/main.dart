import 'package:ibitf_app/home.dart';
import 'package:ibitf_app/login.dart';
import 'package:ibitf_app/notifservice.dart';
import 'package:ibitf_app/service/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ibitf_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background Message received: ${message.notification?.title}");
  // GlobalVariables.instance.hasnewmsg = true;
  // print("hehe background${GlobalVariables.instance.hasnewmsg}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    // webProvider is optional; use only if you're building for web
    // webProvider: ReCaptchaV3Provider('your-site-key'),
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  // await GlobalVariables.instance.loadHasNewMsg();
  // TODO: Request permission
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }
  // TODO: Register with FCM

  // TODO: Set up foreground message handler
  // TODO: Set up background message handler
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.deepOrange,
        ),
        home: AuthMethods.user != null ? const Home() : const LogIn());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const LoginScreen(),
//     );
//   }
// }

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth < 600) {
//             return const LoginMobile();
//           } else if (constraints.maxWidth > 600 && constraints.maxWidth < 900) {
//             return const LoginTablet();
//           } else {
//             return const LoginDesktop();
//           }
//         },
//       ),
//     );
//   }
// }

// class LoginMobile extends StatefulWidget {
//   const LoginMobile({Key? key}) : super(key: key);

//   @override
//   State<LoginMobile> createState() => _LoginMobileState();
// }

// class _LoginMobileState extends State<LoginMobile> {
//   bool _isChecked = false;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 40),
//       child: SingleChildScrollView(
//         child: SizedBox(
//           // width: 300,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Image.asset('assets/image 1.png', scale: 3),
//               Text(
//                 'Welcome!',
//                 style: GoogleFonts.inter(
//                   fontSize: 17,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Login to your account',
//                 style: GoogleFonts.inter(
//                   fontSize: 23,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 35),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   hintText: 'abc@example.com',
//                   labelStyle: GoogleFonts.inter(
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                   enabledBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Colors.grey,
//                       width: 1,
//                     ),
//                   ),
//                   focusedBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Colors.grey,
//                       width: 1,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: '********',
//                   labelStyle: GoogleFonts.inter(
//                     fontSize: 14,
//                     color: Colors.black,
//                   ),
//                   enabledBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Colors.grey,
//                       width: 1,
//                     ),
//                   ),
//                   focusedBorder: const OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Colors.grey,
//                       width: 1,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 25),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Flexible(
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           height: 24,
//                           width: 24,
//                           child:
//                               Checkbox(value: _isChecked, onChanged: onChanged),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Remember me',
//                           style: GoogleFonts.inter(
//                             fontSize: 14,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 25),
//                   Flexible(
//                     child: Text(
//                       'Forgot password?',
//                       style: GoogleFonts.inter(
//                         fontSize: 14,
//                         color: const Color.fromARGB(255, 0, 84, 152),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               TextButton(
//                 onPressed: () {},
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 20,
//                     horizontal: 10,
//                   ),
//                 ),
//                 child: Text(
//                   'Login now',
//                   style: GoogleFonts.inter(
//                     fontSize: 15,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               TextButton(
//                 onPressed: () {},
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 20,
//                     horizontal: 10,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset('assets/google.png'),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Continue with Google',
//                       style: GoogleFonts.inter(
//                         fontSize: 15,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void onChanged(bool? value) {
//     setState(() {
//       _isChecked = value!;
//     });
//   }
// }

// class LoginTablet extends StatefulWidget {
//   const LoginTablet({Key? key}) : super(key: key);

//   @override
//   State<LoginTablet> createState() => _LoginTabletState();
// }

// class _LoginTabletState extends State<LoginTablet> {
//   bool _isChecked = false;
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         width: 350,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Welcome back',
//               style: GoogleFonts.inter(
//                 fontSize: 17,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Login to your account',
//               style: GoogleFonts.inter(
//                 fontSize: 23,
//                 color: Colors.black,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 35),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Email',
//                 hintText: 'abc@example.com',
//                 labelStyle: GoogleFonts.inter(
//                   fontSize: 14,
//                   color: Colors.black,
//                 ),
//                 enabledBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1,
//                   ),
//                 ),
//                 focusedBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 hintText: '********',
//                 labelStyle: GoogleFonts.inter(
//                   fontSize: 14,
//                   color: Colors.black,
//                 ),
//                 enabledBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1,
//                   ),
//                 ),
//                 focusedBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Colors.grey,
//                     width: 1,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 25),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: Checkbox(value: _isChecked, onChanged: onChanged),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Remember me',
//                       style: GoogleFonts.inter(
//                         fontSize: 14,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 25),
//                 Text(
//                   'Forgot password?',
//                   style: GoogleFonts.inter(
//                     fontSize: 14,
//                     color: const Color.fromARGB(255, 0, 84, 152),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             TextButton(
//               onPressed: () {},
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 20,
//                   horizontal: 10,
//                 ),
//               ),
//               child: Text(
//                 'Login now',
//                 style: GoogleFonts.inter(
//                   fontSize: 15,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextButton(
//               onPressed: () {},
//               style: TextButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 20,
//                   horizontal: 10,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/google.png'),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Continue with Google',
//                     style: GoogleFonts.inter(
//                       fontSize: 15,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void onChanged(bool? value) {
//     setState(() {
//       _isChecked = value!;
//     });
//   }
// }

// class LoginDesktop extends StatefulWidget {
//   const LoginDesktop({Key? key}) : super(key: key);

//   @override
//   State<LoginDesktop> createState() => _LoginDesktopState();
// }

// class _LoginDesktopState extends State<LoginDesktop> {
//   bool _isChecked = false;
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(child: Image.asset('assets/image 1.png', fit: BoxFit.cover)),
//         Expanded(
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 21),
//             padding: const EdgeInsets.symmetric(horizontal: 50),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   'Welcome back',
//                   style: GoogleFonts.inter(
//                     fontSize: 17,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Login to your account',
//                   style: GoogleFonts.inter(
//                     fontSize: 23,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 35),
//                 TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     hintText: 'abc@example.com',
//                     labelStyle: GoogleFonts.inter(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                     enabledBorder: const OutlineInputBorder(
//                       borderSide: BorderSide(
//                         color: Colors.grey,
//                         width: 1,
//                       ),
//                     ),
//                     focusedBorder: const OutlineInputBorder(
//                       borderSide: BorderSide(
//                         color: Colors.grey,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     hintText: '********',
//                     labelStyle: GoogleFonts.inter(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                     enabledBorder: const OutlineInputBorder(
//                       borderSide: BorderSide(
//                         color: Colors.grey,
//                         width: 1,
//                       ),
//                     ),
//                     focusedBorder: const OutlineInputBorder(
//                       borderSide: BorderSide(
//                         color: Colors.grey,
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           height: 24,
//                           width: 24,
//                           child: Checkbox(
//                             value: _isChecked,
//                             onChanged: onChanged,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Remember me',
//                           style: GoogleFonts.inter(
//                             fontSize: 14,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 25),
//                     Text(
//                       'Forgot password?',
//                       style: GoogleFonts.inter(
//                         fontSize: 14,
//                         color: const Color.fromARGB(255, 0, 84, 152),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 TextButton(
//                   onPressed: () {},
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 20,
//                       horizontal: 10,
//                     ),
//                   ),
//                   child: Text(
//                     'Login now',
//                     style: GoogleFonts.inter(
//                       fontSize: 15,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 TextButton(
//                   onPressed: () {},
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 20,
//                       horizontal: 10,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset('assets/google.png'),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Continue with Google',
//                         style: GoogleFonts.inter(
//                           fontSize: 15,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void onChanged(bool? value) {
//     setState(() {
//       _isChecked = value!;
//     });
//   }
// }
