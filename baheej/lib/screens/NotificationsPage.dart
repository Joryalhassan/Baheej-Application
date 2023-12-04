import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/backasf.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: kToolbarHeight +
                    0), // Add padding to account for the AppBar height plus additional space
            child: CardListView(),
          ),
        ],
      ),
    );
  }
}

class CardListView extends StatelessWidget {
  final _random = Random();
  final List<Color> _randomColors = [
    Color.fromARGB(255, 249, 194, 212),
    Color.fromARGB(255, 210, 229, 245),
    const Color.fromARGB(255, 255, 242, 123),
    // Add more colors if needed
  ];

  Color _getRandomColor() {
    return _randomColors[_random.nextInt(_randomColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('notification2').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final notifications = snapshot.data?.docs;

        if (notifications == null || notifications.isEmpty) {
          return Center(
            child: Text('No notifications available.'),
          );
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification =
                notifications[index].data(); // Access the data map
            final message = notification['message'];
            var centerName = notification['centerName'];

            if (centerName == null) {
              centerName = 'Unknown Center'; // Provide a default value
            }

            // Use the same random color logic as in KidCard
            Color randomColor = _getRandomColor();

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: randomColor,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Center Name: fun for kids',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: '5yearsoldfont',
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
