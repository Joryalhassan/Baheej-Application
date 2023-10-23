import 'package:flutter/material.dart';

class EditService extends StatefulWidget {
 
  final String fieldLabel;
  final String? currentValue;
  final Function(String?) onSave;

  EditService({
    required this.fieldLabel,
    required this.currentValue,
    required this.onSave,
  });
 
  @override
  _EditServiceState createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final TextEditingController _controller = TextEditingController();
  String? editedValue;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.fieldLabel}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit ${widget.fieldLabel}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter ${widget.fieldLabel}',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  editedValue = _controller.text;
                });

                widget.onSave(editedValue);

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
//In your original ServiceFormScreen, add edit buttons for each field, and when a user clicks the edit button, navigate to the corresponding edit page. Here's an example of how to add an edit button for the "Service Name" field:
//dart
//Copy code
//ElevatedButton(
 // onPressed: () {
 //   Navigator.push(
  //    context,
  //    MaterialPageRoute(
   //     builder: (context) => EditService(
          //fieldLabel: 'Service Name',
         /// currentValue: serviceName,
         // onSave: (newValue) {
         //   setState(() {
         //     serviceName = newValue;
         //   });
        //  },
      //  ),
     // ),
   // );
 // },
//  child: Text('Edit Service Name'),
//),