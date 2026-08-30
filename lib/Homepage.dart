import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Homepage extends StatefulWidget
{
  const Homepage({super.key});

  @override
  State<Homepage> createState() => State_Homepage() ;
  
}

// ignore: camel_case_types
class State_Homepage extends State<Homepage> 
{
    String username = "" ;

  Future<void> getUsername () async
  {
    
    User? user = FirebaseAuth.instance.currentUser ;

    if(user==null) 
    {
      return ;
    }

  // Sign In With Google

    if(user.displayName!=null)
    {
      setState(() {
        username = user.displayName! ;
      });
    }
    
    // Sign In With Email and Password

    else
    {
      DocumentSnapshot userdata = await FirebaseFirestore.instance
      .collection("Users").doc(user.uid).get() ;

    if(userdata.exists)
    {
      setState(() {
      username =  userdata["Username"] ;
      });
    }
    }

  }

  @override
  void initState()
    {
      super.initState() ;
      getUsername() ;
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
      elevation: 10,
      backgroundColor: Colors.blue,
      title: const Text("HomePage"),
      titleTextStyle: const TextStyle(
        color: Colors.white ,
        fontSize: 20 ,
        fontWeight: FontWeight.w700
      ),
      actions: [
        IconButton(
          onPressed: () async {

            GoogleSignIn googleSignIn = GoogleSignIn.instance ;
            await googleSignIn.disconnect();

            await FirebaseAuth.instance.signOut();

            // ignore: use_build_context_synchronously
            Navigator.of(context).pushNamedAndRemoveUntil(
              "LogIn", 
              (route) => false 
              );
          }, 
          icon: const Icon(Icons.exit_to_app,color: Colors.white,) ,
          ),
      ],
      ),
      body: Container(
        
        padding: const EdgeInsets.all(20),

        child: Text(
          username.isEmpty ? "Name is not found"
          : "Hello $username" ,
          style: const TextStyle(
            fontSize: 25 ,
            fontWeight: FontWeight.bold  ,
            color: Colors.purple ,
          ),
        )

      ),
    );
    
  }
  
}