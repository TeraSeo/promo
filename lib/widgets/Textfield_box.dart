import 'package:flutter/material.dart';

class TextField_resultBx extends StatelessWidget {
  const TextField_resultBx({
    Key? key,
    required this.boxResultTitle,
    required this.borderLabelTextBox,
    required this.displayBoxResult,
  }) : super(key: key);

  final String boxResultTitle;
  final String borderLabelTextBox;
  final String displayBoxResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            boxResultTitle,
            textScaleFactor: 1.2,
            softWrap: true,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Results Box 1:
          TextField(
            // enabled: true,
            readOnly: false,
            style: const TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              enabled: true,
              contentPadding: const EdgeInsets.all(18.0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              // Border Label TextBox 1
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              hintText: displayBoxResult,
              hintMaxLines: 2,
              hintStyle: const TextStyle(
                color: Colors.black,
              ),
              enabledBorder: myinputborder(context),
              focusedBorder: myfocusborder()
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder myinputborder(BuildContext context){ //return type is OutlineInputBorder
    return OutlineInputBorder( //Outline border type for TextFeild
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
          color:Theme.of(context).primaryColor,
          width: 3,
        )
    );
  }

  OutlineInputBorder myfocusborder(){
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
          color:Colors.greenAccent,
          width: 3,
        )
    );
  }
}