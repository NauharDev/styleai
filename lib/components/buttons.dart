import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart'; 
import 'package:n_a_w/authentication/auth_services.dart';

class SquareTile extends StatelessWidget {
  final String? purpose;
  final String imagePath;
  const SquareTile({this.purpose, required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: const BorderRadius.all(Radius.circular(9.0)),
          border: Border.all(color: Colors.black)
        ),
    
        child: Image.asset(imagePath),
        
      ),
      onTap: () {
        AuthService.signInWithGoogle();
      },
    );
  }
}