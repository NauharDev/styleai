import 'package:flutter/cupertino.dart';
import 'package:n_a_w/components/buttons.dart';

import 'widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'globals.dart' as globals;


// class PostHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(context) {
//     return super.createHttpClient(context)
//     ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }


final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  globals.cameras = await availableCameras();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // runApp(MaterialApp(home: HomeScreen(globals.cameras)));
  runApp(MaterialApp(debugShowCheckedModeBanner: false, navigatorKey: navigatorKey, home: const MainPage(), theme: ThemeData(appBarTheme: const AppBarTheme(shadowColor: null, elevation: 0), scaffoldBackgroundColor: Colors.lightBlueAccent, textTheme: const TextTheme(headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22), headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), bodyMedium: TextStyle(color: Colors.white, fontSize: 16.0), bodyLarge: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16.0)))));
}


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold (
    body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child:  CircularProgressIndicator(),);
        }
        else if (snapshot.hasError) {
          return const Text('something went wrong');
        }
        else if (snapshot.hasData) {
          print(FirebaseAuth.instance.currentUser!.providerData);
          return HomeScreen(globals.cameras);
        }
        else {
          return SignInTemplate();
        }
      },
    )
  );
  
  
}

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const HomeScreen(this.cameras, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('StyleAI'),
        actions: [
           PopupMenuButton(
            onSelected: (value) {value;},
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: FirebaseAuth.instance.signOut(),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(CupertinoIcons.arrowshape_turn_up_left_fill, color: Colors.black,),
                        ),
                        TextSpan(text: '  Sign Out', style: TextStyle(color: Colors.black))
                      ]
                    )
                  )
                )
                
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: [
                Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100))
                    ),
                    child: FirebaseAuth.instance.currentUser!.photoURL != null
                     ? ClipOval(child: Image.network(FirebaseAuth.instance.currentUser!.photoURL!, width: MediaQuery.of(context).size.width / 7, height: MediaQuery.of(context).size.width / 7))
                     : const Icon(CupertinoIcons.person)
                  ),
              
                Wrap(
                  direction: Axis.vertical, 
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  
                  children: [
                    Text(FirebaseAuth.instance.currentUser!.displayName!, style: Theme.of(context).textTheme.headlineLarge), 
                    Text(FirebaseAuth.instance.currentUser!.email!, style: Theme.of(context).textTheme.headlineMedium)
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                LargeTile(color: Colors.lightBlue[900], iconImage: Image.asset('assets/brown_flannel.png'), text: "Colour Suggestions",), 
              ],
            ),
          )
        ],
      )
      // body: Center(
      //   child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         ElevatedButton(
      //           child: const Text('Scan Clothing Item'),
      //           onPressed: () => {
      //             Navigator.push(
      //               context, MaterialPageRoute(
      //                 builder: (context) => TakePictureScreen(cameras, globals.imagePaths))
      //             )
      //           },
      //         ),
      //       ],
      //     ),
      // ),
      );

  }

}

