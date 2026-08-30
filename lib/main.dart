import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my/Homepage.dart';
import 'package:my/SignUp.dart';
import 'package:my/loginpage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

runApp(const MyApp());

}

class MyApp extends StatefulWidget
{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => State_MyApp() ;
  
}

// ignore: camel_case_types
class State_MyApp extends State<MyApp>
{

  @override
  void initState ()
  {
    FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
  super.initState() ;
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: (FirebaseAuth.instance.currentUser!=null && 
              FirebaseAuth.instance.currentUser!.emailVerified) 
              ? const Homepage() 
              : const LoginPage() ,
      
      routes: 
      {
        "LogIn" : (context) => const LoginPage() ,
        "SignUp" : (context) => const SignUpPage() ,
        "HomePage" : (context) => const Homepage() ,
      },
      
    );

  }
  
  

}

