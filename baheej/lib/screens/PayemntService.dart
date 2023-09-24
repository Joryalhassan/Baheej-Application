import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService extends StatefulWidget {
  final String serviceName;
  final double servicePrice; // Add the service price here
  final List<String> selectedKids;

  PaymentService({
    required this.serviceName,
    required this.servicePrice,
    required this.selectedKids,
  });

  @override
  _PaymentServiceState createState() => _PaymentServiceState();
}

class _PaymentServiceState extends State<PaymentService> {
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    // Calculate the total based on the selected kids and service price
    total = widget.selectedKids.length.toDouble() * widget.servicePrice;
  }

  // Function to process the payment (you can implement your payment logic here)
  Future<void> processPayment() async {
    // Replace this with your payment processing logic
    // For example, you can use a payment gateway or a custom method
    try {
      // Process the payment here

      // If payment is successful, you can show a success message and navigate back
      // to the previous page or any other desired navigation logic.

      // For now, let's print a success message
      print('Payment Successful');
    } catch (error) {
      // Handle payment failure here
      print('Payment Error: $error');
      // You can show an error message to the user if needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment for ${widget.serviceName}'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Name:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              widget.serviceName,
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 17, 0, 6),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Service Price:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '\$${widget.servicePrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 7, 0, 2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Kids:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // StreamBuilder to display kids from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Kids').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final kids = snapshot.data!.docs;
                List<Widget> checkboxes = [];
                for (var kid in kids) {
                  final kidData = kid.data() as Map<String, dynamic>;
                  final kidName = kidData['name'] as String;
                  checkboxes.add(
                    ListTile(
                      title: Text(kidName),
                      trailing: Checkbox(
                        value: widget.selectedKids.contains(kid.id),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              widget.selectedKids.add(kid.id);
                              total += widget
                                  .servicePrice; // Add the service price for the selected kid
                            } else {
                              widget.selectedKids.remove(kid.id);
                              total -= widget
                                  .servicePrice; // Deduct the service price for the deselected kid
                            }
                          });
                        },
                      ),
                    ),
                  );
                }
                return Column(
                  children: checkboxes,
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call the function to process the payment
                processPayment();
                // You can add navigation logic here if needed
              },
              child: Text('Make Payment (\$${total.toStringAsFixed(2)})'),
            ),
          ],
        ),
      ),
    );
  }
}
