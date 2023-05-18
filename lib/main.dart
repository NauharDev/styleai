import 'package:flutter/cupertino.dart';

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
  runApp(MaterialApp(navigatorKey: navigatorKey, home: const MainPage(), theme: ThemeData(textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white), bodyLarge: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16.0)))));
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
          return HomeScreen(globals.cameras);
        }
        else {
          return SignInTemplate(newUser: false,);
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
      appBar: AppBar(
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
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Scan Clothing Item'),
                onPressed: () => {
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (context) => TakePictureScreen(cameras, globals.imagePaths))
                  )
                },
              ),
            ],
          ),
      ),
      );

  }

}

