import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart' as globals;

class ColourRecScreen extends StatefulWidget {
  const ColourRecScreen({super.key});

  @override
  State<ColourRecScreen> createState() => _ColourRecScreenState();
}

class _ColourRecScreenState extends State<ColourRecScreen> {
  late Stream responses;

  void showErrorDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return const CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('An error occurred when processing your photos. Please end your session or try reloading your photos.'), 
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('End Session')
            ), 
            CupertinoDialogAction(
              child: Text('Reload Photos')
            )
          ],
        );
      },
    );
  }


  Future<http.Response> getData(String imagePath) async {
    Future<http.Response> response = http.get(Uri.parse(
        'https://styleai.pythonanywhere.com/recs?imagePath=$imagePath'));

    return response;
  }

  Future<Stream> createResponseStream() async {
    List<Future> responses = [];
    for (int i = 1; i < globals.imagePaths.length + 1; i++) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String downloadLink = await FirebaseStorage.instance
        .ref()
        .child('$uid/image$i.jpg')
        .getDownloadURL();
      print(downloadLink);
      downloadLink = downloadLink.replaceAll(RegExp(r'/'), '!');
      downloadLink =
      downloadLink.replaceAll(RegExp(r'&'), 'nozzyk');
      downloadLink =
      downloadLink.replaceAll(RegExp(r'%'), 'nozzzyk');
      print(downloadLink);
      Future response = getData(downloadLink);
      responses.add(response);
    }
    return Stream.fromFutures(responses);

  }

  @override
  void initState() async {
    super.initState();
    responses = await createResponseStream();
  }

  @override
  Widget build(BuildContext context) {
    List completeResponses = [];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text('Colour Suggestions', style: Theme.of(context).textTheme.headlineLarge)
      ),
      body: StreamBuilder(
        stream: responses,
        builder:(context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
            var data = snapshot.data as http.Response;
            completeResponses.add(jsonDecode(data.body)['colour_rec']);
            return const Center(child: CupertinoActivityIndicator());
            }
            else if (snapshot.hasError) {
              showErrorDialog();
            }  
          }
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          else {
            /* colour rec screen */
          }
          
          
        },
      )
    );
  }
}
