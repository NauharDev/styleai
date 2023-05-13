import 'dart:io';
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

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  // @override
  // State<StatefulWidget> createState() {
  //  
  //   throw UnimplementedError();
  // }
  
  @override
  SignInScreenState createState() => SignInScreenState();

}

class SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool invalidInput = false;

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StyleAI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Visibility(
                visible: invalidInput,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                   'Both fields are required.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
               SizedBox(
                width: MediaQuery.of(context).size.width - 20.0,
                child: TextField(
                  controller: emailController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'email'
                  ),
                ),
              ),
               SizedBox(
                width: MediaQuery.of(context).size.width - 20.0,
                child: TextField(
                  controller: passController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'password'
                  ),
                ),
              ),
  
            TextButton(
              child: const Text('Submit'),
              onPressed: () => {
                if (emailController.text == '' || passController.text == '') {
                  setState(() {
                    invalidInput = true;
                },),
                }
                else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(globals.cameras),))
                }
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

}



//stateless widget is a dumb widget that paints pixels on the screen
class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const HomeScreen(this.cameras, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StyleAI'),
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
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
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
