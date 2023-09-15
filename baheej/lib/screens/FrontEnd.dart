import 'package:flutter/material.dart';

// big button for (Done, Sign up ,...),(blue)
class CustomBigButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const CustomBigButton({
    required this.text,
    required this.onPressed,
    this.width = 120.0,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 111, 176, 234),
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        minimumSize: Size(width, height),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}

///////////////////////////////////////////////////////////

// small button
class CustomSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const CustomSmallButton({
    required this.text,
    required this.onPressed,
    this.width = 100.0,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 241, 106, 210),
        onPrimary: Color.fromARGB(255, 241, 106, 210),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        minimumSize: Size(width, height),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}

//WHEN YOU WANT TO USE IT
//Example:
//CustomBigButton(
//text: 'Done',
//onPressed: () {
// Button action
//},
//width: 120.0,
//height: 50.0,
//)

///////////////////////////////////////////////////////////

// for text input field
Widget buildStyledTextField({
  required String label,
  required TextEditingController controller,
  required String? Function(String?) validator,
  required IconData icon,
  bool obscureText = false,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.grey[300],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '',
              icon: Icon(icon),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            validator: validator,
            obscureText: obscureText,
          ),
        ),
      ],
    ),
  );
}

///////////////////////////////////////////////////////////

// for drop down button like (gender)
Widget buildStyledDropdownButtonFormField({
  required String label,
  required String? value,
  required void Function(String?) onChanged,
  required List<String> items,
  required String? Function(String?) validator,
  required IconData icon,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.grey[300], // Set the background color to grey
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            items: items
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            decoration: InputDecoration(
              labelText: '',
              icon: Icon(icon),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    ),
  );
}

// big button for Done, Sign up (blue)
//ElevatedButton(
// onPressed: () {
// Button action
//  },
// style: ElevatedButton.styleFrom(
//   primary: Color.fromARGB(255, 111, 176, 234),
//   onPrimary: Colors.white,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(30.0),
//   ),
//   minimumSize: Size(120, 50),
// ),
//  child: Text(
//     'Done',
//     style: TextStyle(fontSize: 20.0),
//   ),
// )

///////////////////////////////////////////////////////////

// small button
// ElevatedButton(
// onPressed: () {
// Button action
// },
//  style: ElevatedButton.styleFrom(
//   primary: Color.fromARGB(255, 241, 106, 210),
//   onPrimary: Color.fromARGB(255, 241, 106, 210),
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(30.0),
//   ),
//   minimumSize: Size(100, 50),
// ),
// child: Text('8-11 AM'),
// )
