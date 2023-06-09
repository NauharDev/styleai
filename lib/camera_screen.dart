import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:n_a_w/components/buttons.dart';
import 'package:path_provider/path_provider.dart';
import 'globals.dart' as globals;
import 'cloud storage/storage.dart';

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<String> imagePaths;
  final bool fromSubmitScreen;
  const TakePictureScreen(this.cameras, this.imagePaths, this.fromSubmitScreen,
      {super.key});

  @override
  // ignore: no_logic_in_create_state
  TakePictureScreenState createState() =>
      TakePictureScreenState(imagePaths: imagePaths);
}

class TakePictureScreenState extends State<TakePictureScreen> {
  TakePictureScreenState({required this.imagePaths});
  List<String> imagePaths;
  bool frontFacing = false;
  bool flashOn = false;
  late CameraController controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = initCamera(widget.cameras[0]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future initCamera(CameraDescription camera) {
    controller = CameraController(camera, ResolutionPreset.medium);
    _initializeControllerFuture = controller.initialize();
    return _initializeControllerFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('Take Photo of Clothing Item'),
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                CameraPreview(controller),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CupertinoButton(
                      child: Icon(
                          flashOn
                              ? CupertinoIcons.bolt_fill
                              : CupertinoIcons.bolt_slash_fill,
                          color: flashOn
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor.withOpacity(0.4),
                          size: MediaQuery.of(context).size.width / 12),
                      onPressed: () async {
                        flashOn = !flashOn;
                        if (flashOn) {
                          await controller.setFlashMode(FlashMode.always);
                        } else {
                          await controller.setFlashMode(FlashMode.off);
                        }
                        setState(() {});
                      },
                    ),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.camera_fill,
                          size: MediaQuery.of(context).size.width / 8,
                          color: Theme.of(context).primaryColor),
                      onPressed: () async {
                        await _initializeControllerFuture;
                        final image = await controller.takePicture();
                        if (!mounted) return;
                        await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayPictureScreen(
                                  imagePath: image.path,
                                  fromSubmitScreen: false),
                            ));
                      },
                    ),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.camera_rotate_fill,
                          size: MediaQuery.of(context).size.width / 8,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        setState(() {
                          initCamera(widget.cameras[frontFacing ? 0 : 1]);
                          frontFacing = !frontFacing;
                        });
                      },
                    )
                  ],
                ), 
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Visibility(
                    visible: globals.imagePaths.isNotEmpty,
                    child: CupertinoButton(
                      color: Theme.of(context).primaryColor,
                      child: const Text("View Photos"),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => PhotoSubmitScreen(imagePaths: globals.imagePaths),
                          )
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: Colors.lightBlue[900]),
            );
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final bool fromSubmitScreen;
  final Storage storageBucket = Storage();

  DisplayPictureScreen(
      {required this.imagePath, required this.fromSubmitScreen, super.key});

  Future<String> getDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> saveToImageDirectory(File imageFile) async {
    final directoryPath = await getDirectoryPath();
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final file = File('$directoryPath/$fileName');
    print(file.path);
    await file.writeAsBytes(imageFile.readAsBytesSync());
    globals.images.add(file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: Text('StyleAI', style: Theme.of(context).textTheme.headlineLarge),
        ),
        body: Column(children: [
          Expanded(child: Image.file(File(imagePath))),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: CupertinoButton(
                color: Theme.of(context).primaryColor,
                child: const Text('Save Image'),
                onPressed: () {
                  switch (globals.imagePaths.length) {
                    case 0:
                      {
                        Storage.uploadPhoto(
                                FirebaseAuth.instance.currentUser!.uid,
                                imagePath,
                                'image1.jpg')
                            .then(
                          (value) {
                            print('done');
                          },
                        );
                        break;
                      }
                    case 1:
                      {
                        Storage.uploadPhoto(
                                FirebaseAuth.instance.currentUser!.uid,
                                imagePath,
                                'image2.jpg')
                            .then(
                          (value) {
                            print('done');
                          },
                        );
                        break;
                      }
                    case 2:
                      {
                        Storage.uploadPhoto(
                                FirebaseAuth.instance.currentUser!.uid,
                                imagePath,
                                'image3.jpg')
                            .then(
                          (value) {
                            print('done');
                          },
                        );
                        break;
                      }
                    case 3:
                      {
                        Storage.uploadPhoto(
                                FirebaseAuth.instance.currentUser!.uid,
                                imagePath,
                                'image4.jpg')
                            .then(
                          (value) {
                            print('done');
                          },
                        );
                        break;
                      }
                    case 4:
                      {
                        Storage.uploadPhoto(
                                FirebaseAuth.instance.currentUser!.uid,
                                imagePath,
                                'image5.jpg')
                            .then(
                          (value) {
                            print('done');
                          },
                        );
                        break;
                      }
                  }
                  globals.imagePaths.add(imagePath);
                  if (fromSubmitScreen ||
                      globals.imagePaths.length == 5) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoSubmitScreen(
                              imagePaths: globals.imagePaths),
                        ));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TakePictureScreen(
                              globals.cameras, globals.imagePaths, false),
                        ));
                  }
                }),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
            child: CupertinoButton(
              color: Theme.of(context).primaryColor,
              child: const Text('Retake'),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakePictureScreen(
                          globals.cameras, globals.imagePaths, false),
                    ));
              },
            ),
          ),
        ]));
  }
}

class PhotoSubmitScreen extends StatelessWidget {
  final List<String> imagePaths;
  const PhotoSubmitScreen({required this.imagePaths, super.key});

  List<Widget> arrangePhotos(List<String> imagePaths) {
    List<Widget> photoTiles = [];
    for (String path in imagePaths) {
      photoTiles.add(PhotoTile(colour: Colors.lightBlue[900], image: Image.file(File(path)), noPhoto: false,));
    }
    return photoTiles;
  }

  Future getData(String imagePath) async {
    // String modified = imagePath.replaceAll(RegExp(r'/'), '+');
    // Uint8List encodedList = ascii.encode(imagePath);
    // String base64Message = base64.encode(encodedList);
    // print(imagePath);
    http.Response response = await http.get(Uri.parse(
        'https://5a68-24-150-91-41.ngrok-free.app/recs?imagePath=$imagePath'));

    // Uri uri = Uri.parse('http://127.0.0.1:3333/recs?imagePath=$modified');
    // print(uri);
    // print(uri.toString() == 'http://127.0.0.1:3333/recs?imagePath=L1VzZXJzL25hdWhhcmthcHVyL0RvY3VtZW50cy9OaWdodHMtYW5kLVdlZWtlbmRzL2xpYi9JTUdfMzc2NC5qcGc=');

    // http.Response response = await http.get(uri);
    // print(response);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> photoTiles = arrangePhotos(imagePaths);
    int i = 5 - photoTiles.length;
    while (i > 0) {
      photoTiles.add(PhotoTile(colour: Theme.of(context).primaryColor, image: Image.asset("assets/white_tee.png", scale: 2), noPhoto: true,));
      i -= 1;
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: Text('View Photos', style: Theme.of(context).textTheme.headlineLarge),
        ),
        body: Column(
          children: [
            Flexible(
              flex: 4,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 20,
                children: photoTiles
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColorLight, 
                      offset: const Offset(-4, -4), 
                      blurRadius: 6
                    ), 
                    BoxShadow(
                      color: Theme.of(context).primaryColorDark, 
                      offset: const Offset(4, 4), 
                      blurRadius: 6

                    )
                  ]
                ),
                child: CupertinoButton(
                  color: Theme.of(context).primaryColor,
                  child: const Text('Get colour suggestions!'),
                  onPressed: () async {
                    String uid = FirebaseAuth.instance.currentUser!.uid;
                    String downloadLink = await FirebaseStorage.instance
                        .ref()
                        .child('$uid/image1.jpg')
                        .getDownloadURL();
                    print(downloadLink);
                    downloadLink = downloadLink.replaceAll(RegExp(r'/'), '!');
                    downloadLink =
                        downloadLink.replaceAll(RegExp(r'&'), 'nozzyk');
                    downloadLink =
                        downloadLink.replaceAll(RegExp(r'%'), 'nozzzyk');
                    print(downloadLink);
                    http.Response response = await getData(downloadLink);
                    var decodedData = jsonDecode(response.body);
                    print(decodedData['colour_rec']);
                  },
                ),
              ),
            )
          ],
        ));
  }
}
