import 'package:flutter/material.dart';

class Signup extends StatelessWidget
{
  final Map<String, dynamic> field;
  final TextEditingController controller;

  const Signup({super.key , required this.field, required this.controller });

  String? validate(String? value) {
    // Common validation
    if (value == null || value.isEmpty) {
      return "The field can't be empty";
    }

    // Username validation
    if (field["Feild_Name"] == "Name") {
      if (value.length >= 13) {
        return "Username must be less than 13 characters";
      }
    }

    // Email validation
    else if (field["Feild_Name"] == "Email") {
      final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return "Please enter a valid email";
      }
    }

    // Password validation
    else if (field["Feild_Name"] == "Password") {
      if (value.length < 8) {
        return "Password must be at least 8 characters";
      }

      if (value.length > 12) {
        return "Password must be less than 13 characters";
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(field["Feild_Name"] , style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25 , 
                  fontWeight: FontWeight.w500 
                )
                ), 
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
              validator: validate ,
              obscureText: field["Feild_Name"]=="Password" ? true : false  ,
              controller: controller ,
              keyboardType: field["Feild_Name"]=="Email"? TextInputType.emailAddress : TextInputType.text  ,
              decoration: InputDecoration(
                fillColor: const Color(0xFFFBF9FC),
                filled: true,
                prefixIcon: Icon(field["Icon_Name"], size: 30, color: const Color.fromRGBO(119, 115, 134, 0.926)),
                contentPadding: const EdgeInsets.all(18) ,
                hintText: field["hint_Text"] ,
                hintStyle: const TextStyle(color: Colors.grey , fontSize: 20) ,
                enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)) ,
                    borderSide: BorderSide.none ,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)) ,
                  borderSide: BorderSide.none ,
                )
              ),
            ),
            ),
            const SizedBox(height: 20),
              ]
              );
  }
  
}