
 import 'package:flutter/material.dart'; 



// big button for (Done, Sign up ,...),(blue)
class CustomBigButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomBigButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 59, 138, 207),
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        minimumSize: Size(100, 40),
      ),
      onPressed: onPressed,
      child: Text(text),
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
class buildStyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? icon;

  const buildStyledTextField({
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[300],
          contentPadding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          labelText: labelText,
          icon: icon != null ? Icon(icon) : null,
        ),
        validator: validator,
      ),
    );
  }
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
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    ),
  );
}








