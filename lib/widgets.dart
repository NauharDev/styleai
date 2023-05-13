import 'package:flutter/material.dart';
import 'main.dart';
import 'globals.dart' as globals;
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ignore: must_be_immutable
class SignInTemplate extends StatefulWidget {
  bool newUser;
  SignInTemplate({required this.newUser, super.key});

  @override
  State<SignInTemplate> createState() => _SignInTemplateState();
}

class _SignInTemplateState extends State<SignInTemplate> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();
  bool invalidInput = false;
  bool signInError = false;


    Future signIn() async {
    showDialog(
      context: context, 
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim()
      );
    }
    on FirebaseAuthException {
      setState(() {
        signInError = true;
      });
    }
    print('hello');
    navigatorKey.currentState!.popUntil((route) => route.isFirst,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StyleAI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
              Text(widget.newUser ? 'Sign Up' : 'Log In', style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(flex: 4),
              Visibility(
                visible: invalidInput || signInError,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.red
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    invalidInput ? 'All fields are required.' : 'Invalid sign-in credentials. Please try again.',
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
                  onChanged: (value) {
                    if (emailController.text == '' || passController.text == '' || ( widget.newUser && confirmController.text == '')) {
                      return;
                    }
                    else {
                      setState(() {
                        invalidInput = false;
                      });
                    }
                  },
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
                  onChanged: (value) {
                    if (emailController.text == '' || passController.text == '' || ( widget.newUser && confirmController.text == '')) {
                      return;
                    }

                    else {
                      setState(() {
                        invalidInput = false;
                      });
                    }
                  },
                ),
              ),
              Visibility(
                visible: widget.newUser,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 20.0,
                  child: TextField(
                    controller: confirmController,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'confirm password', 
                    ),
                    onChanged: (value) {
                    if (emailController.text == '' || passController.text == '' || ( widget.newUser && confirmController.text == '')) {
                      return;
                    }
                    else {
                      setState(() {
                        invalidInput = false;
                      });
                    }
                    },
                  ),
                ),
              ),
              TextButton(
                child: Text(widget.newUser ? 'Have an account? Click here to log in!' : 'Don\'t have an account? Click here to sign up!'), 
                onPressed: () {
                  widget.newUser ? Navigator.pop(context) : 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignInTemplate(newUser: !widget.newUser,),));
                },
              ),
            Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF0D47A1),
                          Color(0xFF1976D2),
                          Color(0xFF42A5F5),
                        ]
                      )
                    )
                  )
                ),
                TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 18.0)),
                onPressed: ()  {
                  if (emailController.text == '' || passController.text == '' || ( widget.newUser && confirmController.text == '')) {
                    setState(() {
                      invalidInput = true;
                  },);
                  }
                  else if (widget.newUser) {
                    //create new account
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(globals.cameras),));
                  }
                  else {
                    signIn();
                  }
                  },
                ),
              ]
            ),
            const Spacer(flex: 2),
            // Flexible(
            //   fit: FlexFit.tight,
            //   child: StreamBuilder(
            //     stream: FirebaseAuth.instance.authStateChanges(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(child: CircularProgressIndicator());
            //       }
            //       else if (snapshot.hasError) {
            //         return Container(
            //           decoration: const  BoxDecoration(
            //             borderRadius: BorderRadius.all(Radius.circular(10)),
            //             color: Colors.red,
            //           ),
            //           child: Text('Invalid sign-in credentials. Please try again.', 
            //             style: Theme.of(context).textTheme.bodyMedium,),
            //         );
            //       }
            //       else {
            //         return HomeScreen(globals.cameras);
            //       }
            //     },
            //   ),
            // )

          ],
        ),
      ),
    );
  }
}