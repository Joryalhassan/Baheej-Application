import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:flutter/material.dart';

class HomeScreenCenter extends StatefulWidget {
  const HomeScreenCenter({Key? key}) : super(key: key);

  @override
  _HomeScreenCenterState createState() => _HomeScreenCenterState();
}

class _HomeScreenCenterState extends State<HomeScreenCenter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Logout"),
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              print("Signed Out");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignInScreen())); 
            });
          },
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:baheej/screens/auth.dart';

// class HomePage extends StatelessWidget {
//   final User? user = Auth().currentUser; // Declare the type explicitly

//   HomePage({Key? key}) : super(key: key);

//   Future<void> signout() async {
//     await Auth().signout();
//   }

//   Widget _title() {
//     return const Text("firebase Auth");
//   }

//   Widget _ueserUid() {
//     return Text(user?.email ?? 'User email');
//   }

//   Widget _signOutButton() {
//     return ElevatedButton(onPressed: signout, child: const Text('signout'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: _title(),
//       ),
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[],
//         ),
//       ),
//     );
//   }
// }
