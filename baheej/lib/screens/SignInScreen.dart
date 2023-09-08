import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'package:baheej/screens/home-page.dart';
import 'package:baheej/utlis/utilas.dart';
import 'package:baheej/screens/home-page.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  //najd added
  TextEditingController _PhoneNumTextController = TextEditingController();
  TextEditingController _AddressTextController = TextEditingController();
  TextEditingController _ComRegTextController = TextEditingController();
  TextEditingController _DescriptionTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                //1
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Center Name", Icons.person_outline,
                    false, _userNameTextController),
                //2
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Enter Email Id", Icons.email, false, _emailTextController),

                //3
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Phone Number", Icons.phone, false,
                    _PhoneNumTextController),

                //4
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Enter Address", Icons.home, false, _AddressTextController),
                //5
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Commercial Register", Icons.numbers,
                    false, _ComRegTextController),

                //6
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Description", Icons.description, false,
                    _DescriptionTextController),
                //3
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outlined, true,
                    _passwordTextController),

                const SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "Sign Up", () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
                    print("Created New Account");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  }).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });
                })
              ],
            ),
          ))),
    );
  }
}