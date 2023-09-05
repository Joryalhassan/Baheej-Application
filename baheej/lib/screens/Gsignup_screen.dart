
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> creatState() => _SignUpState();
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _SignUpState extends State<SignUp> { 
  final auth = FirebaseAuth.instance;
  var showpass = true;
  late String email ; 
  late String password ; 

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 91, 3, 108),
        title: const Center(
          child: Text(
            'Sign up now',
            style: TextStyle(color: Colors.white)),
          )),
      body: Center(
        child:SafeArea(
          child:SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children : [ 
                    Text(
                  'welcome sign up now',
                  style: TextStyle(fontSize: 20),
                    ), //text
                    
                    SizedBox( height: 20), // sizedbox

                  Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                  hintText: 'email' ,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),

                    ),
                    
                    ),

                    ), // padding
                  
                  SizedBox(
                  height: 20,
                  ), // sizedbox

                  Padding ( 
                    padding: const EdgeInsets.all(8.0),
                    child: TextField( 
                      onChanged: (value) {
                        password = value;
                      },
                      obscureText: showpass ,
                      decoration: InputDecoration( 
                        suffixIcon: IconButton(
                  onPressed: () {
                  setState(( ) {
                  showpass = false;
                  } );
                  },
                  icon: Icon(Icons.password)), // iconbutton
                  hintText: 'password',
                  border: OutlineInputBorder(  
                    borderRadius: BorderRadius.circular(40), 
                  ),
                ), // inputdecoration
               ), 
             ), // padding
              
              SizedBox(height: 20),
              ElevatedButton(onPressed: () async { 
                try {
                var user = await auth.createUserWithEmailAndPassword(email: email, password: password);
     // Navigator.push(context, MaterialPageRoute(builder: (context) => HOMESCREEN),));
                } catch (e) {
                  print(e);
                }
        
              },  child: Text('signup'))
                ],
            ), //column
          ), // singlechildscrollview
        ), //safearea
      ), // ce
     );
  }

}