import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'package:baheej/utlis/utilas.dart'; // تأكد من استيراد المكتبة الصحيحة
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailTextController = TextEditingController();

  String? emailErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Reset Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                // Email Input Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enter Email Id",
                        style: TextStyle(color: Colors.white)),
                    TextField(
                      controller: _emailTextController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        errorText:
                            emailErrorText, // عرض رسالة الخطأ لحقل البريد الإلكتروني
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "Reset Password", () {
                  final email = _emailTextController.text.trim();

                  setState(() {
                    // إعادة تعيين رسالة الخطأ
                    emailErrorText = null;
                  });

                  if (email.isEmpty) {
                    setState(() {
                      emailErrorText = 'Email is required';
                    });
                  }

                  if (emailErrorText == null) {
                    // إذا كان حقل البريد الإلكتروني غير فارغ
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email)
                        .then((value) {
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      print("Error: $error");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Invalid email address'),
                        backgroundColor: Color.fromARGB(255, 245, 19, 3),
                      ));
                    });
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
