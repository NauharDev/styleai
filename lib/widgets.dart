import 'package:n_a_w/cloud storage/storage.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'globals.dart' as globals;
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'components/buttons.dart';

// ignore: must_be_immutable
class SignInTemplate extends StatefulWidget {
  SignInTemplate({super.key});

  @override
  State<SignInTemplate> createState() => _SignInTemplateState();
}

class _SignInTemplateState extends State<SignInTemplate> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmController = TextEditingController();
  bool newUser = true;
  bool invalidInput = false;
  bool signInError = false;
  String errorText = '';

  Future signUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim())
          .then((value) async {
            await FirebaseAuth.instance.currentUser!.updateDisplayName(nameController.text.trim().replaceAll(RegExp(r' '), '_'));
          },);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          signInError = true;
          errorText =
              'The given email address is already in use. Please use a different email.';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          signInError = true;
          errorText = 'The given email address is invalid. Please try again.';
        });
      } else if (e.code == 'weak-password') {
        setState(() {
          signInError = true;
          errorText =
              'The given password is too weak. Please use a stronger password.';
        });
      }
    }
    globals.storageName = nameController.text.trim();
    print(FirebaseAuth.instance.currentUser!.displayName);
    Storage.createStorage(FirebaseAuth.instance.currentUser!.uid);
    print(FirebaseAuth.instance.currentUser!.providerData);
    navigatorKey.currentState!.pop();
  }

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
          password: passController.text.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        setState(() {
          signInError = true;
          errorText = 'The given email address is invalid. Please try again.';
        });
      } else if (e.code == 'user-disabled') {
        setState(() {
          signInError = true;
          errorText =
              'The given user is disabled. Please sign in with a different account.';
        });
      } else if (e.code == 'user-not-found') {
        setState(() {
          signInError = true;
          errorText =
              'There is no user associated with the given email. Please try again.';
        });
      } else {
        setState(() {
          signInError = true;
          errorText = 'The given password is incorrect. Please try again.';
        });
      }
    }
    navigatorKey.currentState!.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'StyleAI',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            Text(newUser ? 'Sign Up' : 'Log In',
                style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(flex: 7),
            Visibility(
              visible: invalidInput || signInError,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: Colors.red),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  invalidInput ? 'All fields are required.' : errorText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            Visibility(
              visible: newUser,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 20.0,
                child: TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: nameController, 
                  autocorrect: false,
                  decoration: InputDecoration(hintText: "Full Name", hintStyle: Theme.of(context).textTheme.bodyMedium),
                  onChanged: (value) {
                    if (emailController.text == '' ||
                        passController.text == '' ||
                        (newUser && (confirmController.text == '' || nameController.text.trim() == ''))) {
                      return;
                    } else {
                      setState(() {
                        invalidInput = false;
                      });
                    }
                    
                  },
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 20.0,
              child: TextField(
                style: Theme.of(context).textTheme.bodyMedium,
                controller: emailController,
                autocorrect: false,
                decoration: InputDecoration(hintText: 'email', hintStyle: Theme.of(context).textTheme.bodyMedium),
                onChanged: (value) {
                  if (emailController.text == '' ||
                      passController.text == '' ||
                      (newUser && (confirmController.text == '' || nameController.text.trim() == ''))) {
                    return;
                  } else {
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
                style: Theme.of(context).textTheme.bodyMedium,
                controller: passController,
                autocorrect: false,
                decoration: InputDecoration(hintText: 'password', hintStyle: Theme.of(context).textTheme.bodyMedium),
                onChanged: (value) {
                  if (emailController.text == '' ||
                      passController.text == '' ||
                      (newUser && (confirmController.text == '' || nameController.text.trim() == ''))) {
                    return;
                  } else {
                    setState(() {
                      invalidInput = false;
                    });
                  }
                  if (passController.text.trim() ==
                      confirmController.text.trim()) {
                    setState(() {
                      signInError = false;
                    });
                  }
                },
              ),
            ),
            Visibility(
              visible: newUser,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 20.0,
                child: TextField(
                  controller: confirmController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'confirm password',
                  ),
                  onChanged: (value) {
                    if (emailController.text == '' ||
                        passController.text == '' ||
                        (newUser && (confirmController.text == '' || nameController.text.trim() == ''))) {
                      return;
                    } else {
                      setState(() {
                        invalidInput = false;
                      });
                    }
                    if (passController.text.trim() ==
                        confirmController.text.trim()) {
                      setState(() {
                        signInError = false;
                      });
                    }
                  },
                ),
              ),
            ),
            TextButton(
              child: Text(newUser
                  ? 'Have an account? Click here to log in!'
                  : 'Don\'t have an account? Click here to sign up!', style: Typography.whiteCupertino.labelSmall,),
              onPressed: () {
                setState(() {
                  signInError = false;
                  invalidInput = false;
                  errorText = '';
                  nameController.text = '';
                  emailController.text = '';
                  passController.text = '';
                  confirmController.text = '';
                  newUser = !newUser;
                });
              },
            ),
            Stack(children: [
              Positioned.fill(
                  child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          gradient: LinearGradient(colors: [
                            Color(0xFF0D47A1),
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ])))),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Submit', style: TextStyle(fontSize: 18.0)),
                onPressed: () {
                  if (emailController.text == '' ||
                      passController.text == '' ||
                      (newUser && (confirmController.text == '' || nameController.text.trim() == ''))) {
                    setState(
                      () {
                        invalidInput = true;
                      },
                    );
                  } else if (newUser) {
                    if (nameController.text.trim().length < 6) {
                      signInError = true;
                      errorText = 'Usernames must be at lease six characters long';
                    }
                    else if (nameController.text.trim().contains('/')) {
                      setState(() {
                        signInError = true;
                        errorText = 'The given name is invalid. Please refrain from using \'/\' in the name.';
                      });
                    }
                    else if (confirmController.text.trim() !=
                        passController.text.trim()) {
                      setState(() {
                        signInError = true;
                        errorText = 'Passwords don\'t match.';
                      });
                    } else {
                      signUp();
                    }
                  } else {
                    signIn();
                  }
                },
              ),
            ]),
            const Spacer(flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Divider(
                  color: Colors.black,
                  thickness: 10.0,
                ),
                Text(
                  'OR',
                  style: Typography.whiteCupertino.labelSmall,
                ),
                const Divider(color: Colors.white, thickness: 10.0)
              ],
            ),

            const Spacer(
              flex: 1,
            ),
            const SquareTile(
              purpose: 'Google',
              imagePath: 'assets/btn_google_light_normal_ios.png',
            ),
            const Spacer(flex: 2)
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
