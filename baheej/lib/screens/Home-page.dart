import 'package:firebase_auth/firebase_auth.dart';
import 'package:baheej/screens/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:baheej/screens/Service.dart';
import 'package:baheej/screens/ServiceForm.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Service> services = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("Signed Out");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                });
              },
              child: Text("Logout"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Navigate to the form screen and wait for the result
                final newService = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ServiceFormScreen()),
                );

                // Check if a new service was returned
                if (newService != null) {
                  setState(() {
                    // Add the new service to the list
                    services.add(newService);
                  });
                }
              },
              child: Text("Add Service"),
            ),
            SizedBox(height: 20),
            Column(
              children: services.map((service) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(service.name),
                    subtitle: Text(
                      'Start Date: ${service.startDate.toLocal().toString().split(' ')[0]} - End Date: ${service.endDate.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
