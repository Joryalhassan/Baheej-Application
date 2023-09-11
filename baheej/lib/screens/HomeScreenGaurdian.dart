import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//<<<<<<< HEAD:baheej/lib/screens/home-page.dart
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/ServiceFormScreen.dart';
import 'package:baheej/screens/Service.dart';
//=======
import 'package:baheej/screens/WelcomePage.dart';
//>>>>>>> origin/main:baheej/lib/screens/HomeScreenGaurdian.dart

class HomeScreenGaurdian extends StatefulWidget {
  const HomeScreenGaurdian({Key? key}) : super(key: key);

  @override
  _HomeScreenGaurdianState createState() => _HomeScreenGaurdianState();
}

<<<<<<< HEAD:baheej/lib/screens/home-page.dart
class _HomeScreenState extends State<HomeScreen> {
  List<Service> services = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Color.fromARGB(255, 98, 144, 224),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Add the logout icon here
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              });
            },
          ),
        ],
////=======
class _HomeScreenGaurdianState extends State<HomeScreenGaurdian> {
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
                  MaterialPageRoute(builder: (context) => WelcomePage())); 
            });
          },
        ),
//>>>>>>> origin/main:baheej/lib/screens/HomeScreenGaurdian.dart
      ),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            color: Color.fromARGB(255, 243, 243, 244),
            elevation: 1,
            margin: EdgeInsets.all(20),
            child: ListTile(
              title: Text(service.name),
              textColor: Color.fromARGB(255, 74, 72, 85),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time: ${service.time.format(context)}'),
                  Text('Price: \$${service.price.toStringAsFixed(2)}'),
                  Text('Description: ${service.description}'),
                  Text('Capacity: ${service.capacity}'),
                  Text('Age: ${service.age}+'),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newService = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceFormScreen(),
              ),
            );

            if (newService != null) {
              setState(() {
                services.add(newService);
              });
            }
          },
          child: Icon(Icons.add),
          backgroundColor: Color.fromARGB(255, 98, 144, 224)),
    );
  }
}
  // List<Service> services = [];
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: ElevatedButton(
  //         child: Text("Logout"),
  //         onPressed: () {
  //           FirebaseAuth.instance.signOut().then((value) {
  //             print("Signed Out");
  //             Navigator.push(context,
  //                 MaterialPageRoute(builder: (context) => SignInScreen()));
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }




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
