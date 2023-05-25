import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart'; 
import 'package:n_a_w/authentication/auth_services.dart';

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
