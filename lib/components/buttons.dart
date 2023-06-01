import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart'; 
import 'package:n_a_w/authentication/auth_services.dart';
import 'dart:math';

import 'package:n_a_w/camera_screen.dart';
import 'package:n_a_w/globals.dart' as globals;

class SquareTile extends StatelessWidget {
  final String purpose;
  final String imagePath;
  const SquareTile({required this.purpose, required this.imagePath, super.key});
  final bool w = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5.0,
        children: [Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
            border: Border.all(color: Colors.black)
          ),
          
          child: Image.asset(imagePath),
          
          ),
          Text("Sign in with $purpose", style: Typography.whiteCupertino.labelSmall)
        ]
      ),
      onTap: () {
        if (purpose == 'Google') {
          AuthService.signInWithGoogle();
        }
      },
    );
  }
}


class LargeTile extends StatelessWidget {
  final String purpose;
  final String text;
  final Image iconImage;
  final Color? color;
  const LargeTile({required this.purpose, required this.text, required this.iconImage, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    // double containerW =  MediaQuery.of(context).size.width / 4;
    // double containerH = (MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom)) / 4;
    return
        GestureDetector(
          onTap: () {
            if (purpose == 'colour recs') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TakePictureScreen(globals.cameras, globals.imagePaths),) );
            }
            else if (purpose == 'closet') {
              
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)), 
              color: color
            ),
            child: Column(
              children: 
              [Expanded(child:iconImage), 
              Text(text, style: Theme.of(context).textTheme.headlineMedium, softWrap: true,),
              const SizedBox(height: 10)]
          ),
            
            ),
        );
  }
}