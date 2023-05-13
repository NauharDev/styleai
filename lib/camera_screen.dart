import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'globals.dart' as globals;





class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<String> imagePaths;
  const TakePictureScreen(this.cameras, this.imagePaths, {super.key});


  @override
  // ignore: no_logic_in_create_state
  TakePictureScreenState createState() => TakePictureScreenState(imagePaths: imagePaths);

}


class TakePictureScreenState extends State<TakePictureScreen> {
  TakePictureScreenState({required this.imagePaths});
  List<String> imagePaths;
  bool frontFacing = false;
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
    bool photosTaken;
    if (imagePaths.isNotEmpty) {
      photosTaken = true;
    } else {
      photosTaken = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('StyleAI'),
      ),
      body: FutureBuilder<void> (
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(controller);
          } else {
            return const Center(child: CircularProgressIndicator(),);
          }
        },
        ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Visibility(
              visible: globals.imagePaths.length < 5 ? true : false,
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;
                    final image = await controller.takePicture();

            
                    if (!mounted) return;
                    saveToImageDirectory(File(image.path));
                    
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          imagePath: image.path,
                        ),
                      )
                    );
                  } catch (e) {
                    // ignore: avoid_print
                    print(e);
                  }
                },
              child: const Icon(Icons.camera_alt)
              ),
            ),
            
            IconButton(
              icon: const Icon(CupertinoIcons.switch_camera), 
              onPressed: () {
                setState(() => frontFacing = !frontFacing);
                initCamera(widget.cameras[frontFacing ? 1 : 0]);
                },
            ),
            Visibility(
              visible: photosTaken,
              child: TextButton(
                child: const Text('View Photos'),
                onPressed: () => {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => PhotoSubmitScreen(imagePaths: imagePaths, imageFiles: globals.images,),))
                },
              ),
            )
            ]
          ),
        ],
      ),
        );

    }
    
  }


class DisplayPictureScreen extends StatelessWidget{
  final String imagePath;


  const DisplayPictureScreen({required this.imagePath, super.key});

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StyleAI'),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Image.file(File(imagePath)),),
            Flexible(
              flex: 1,
              fit: FlexFit.tight, 
              child: TextButton(
                child: const Text('Save Image'),
                onPressed: () => {
                  globals.imagePaths.add(imagePath),
                  Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => TakePictureScreen(globals.cameras, globals.imagePaths),))
                }
              )
            )
        ]
    )
    );
  }


}


class PhotoSubmitScreen extends StatelessWidget {
  final List<String> imagePaths;
  final List<File> imageFiles;
  const PhotoSubmitScreen({required this.imagePaths, required this.imageFiles, super.key});
 
  
  List<Widget> arrangePhotos(List<String> imagePaths) {
    int numRows = (imagePaths.length / 2).round();
    List<Widget> rows = [];
    SizedBox image1 = SizedBox(width: 200, height: 200, child: Image.file(File(imagePaths[0]),)); 
    SizedBox image2 = image1;
    for (int i = 0; i < numRows; i++) {

      if (i == 0) {
        image1 = SizedBox(width: 200, height: 200, child: Image.file(File(imagePaths[0]), )); 
        try {
          image2 = SizedBox(width: 200, height: 200, child: Image.file(File(imagePaths[1]), )); 
        } catch(e) {
          image2 = image1;
        }
      }
      else if (i == 1) {
        image1 = SizedBox(width: 200, height: 200, child: Image.file(File(imagePaths[2]), )); 
        try {
          image2 = SizedBox(width: 200, height: 200, child: Image.file(File(imagePaths[3]), )); 
        } catch(e) {
          image2 = image1;
        }
      }
      else {
        image1 = SizedBox(width: 200, height: 200, child: Image.file(File(imagePaths[4]),)); 
        image2 = image1;
      }
      List<Widget> lst;
      if (image1 != image2) {
        lst = [image1, image2];
      } else {
        lst = [image1];
      }
      Row row = Row(
        children: lst
      );
      rows.add(row);
    }
    
    return rows;
  }

  Future getData(String imagePath) async {
    Dio dio = Dio();
    // String modified = imagePath.replaceAll(RegExp(r'/'), '+');
    // Uint8List encodedList = ascii.encode(imagePath);
    // String base64Message = base64.encode(encodedList);
    print(imagePath);
    Response response = await dio.get('https://5560-24-150-91-41.ngrok-free.app/recs?imagePath=$imagePath');

    // Uri uri = Uri.parse('http://127.0.0.1:3333/recs?imagePath=$modified');
    // print(uri);
    // print(uri.toString() == 'http://127.0.0.1:3333/recs?imagePath=L1VzZXJzL25hdWhhcmthcHVyL0RvY3VtZW50cy9OaWdodHMtYW5kLVdlZWtlbmRzL2xpYi9JTUdfMzc2NC5qcGc=');

    // http.Response response = await http.get(uri);
    print(response);
    return response;
  }


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: const Text('StyleAI'),
      ),
      body: Column(
        children: 
          arrangePhotos(imagePaths) + [TextButton(
            child: const Text('Get colour suggestions!'), 
            onPressed: () async {
              Response response = await getData(imageFiles[0].path);
              // var decodedData = jsonDecode(colourRec);
              // print(decodedData['colour_rec']);
              
            },
          )],
        
      )
    );
  }

}