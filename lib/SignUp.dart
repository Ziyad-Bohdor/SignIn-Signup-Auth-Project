import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my/Auth/SignUpAuth.dart';

class SignUpPage extends StatefulWidget
{
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => StateSignUp() ;

}

class StateSignUp extends State<SignUpPage>
{

  TextEditingController username = TextEditingController() ;
  TextEditingController email = TextEditingController() ;
  TextEditingController password = TextEditingController() ;
  bool loading = false ;

  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  Future<void> signInWithFacebook() async {
  // Trigger the sign-in flow
  final LoginResult loginResult = await FacebookAuth.instance.login();

  // ignore: unnecessary_null_comparison
  if(loginResult.status != LoginStatus.success)
  {
    Navigator.of(context).pushReplacementNamed("SignUp") ;
    return ;
  }

  // Create a credential from the access token
  final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

  // Once signed in, return the UserCredential
  await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

  Navigator.of(context).pushNamedAndRemoveUntil("HomePage", (route)=> false);
}


  Future<void> signInWithGoogle() async {

  try {
       // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate() ;

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    idToken: googleAuth?.idToken,
  ); 

            setState(() {
              loading = true ;
            });
  // Once signed in, return the UserCredential
final userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);

final user = userCredential.user;

if (user != null) {
  await FirebaseFirestore.instance
      .collection("Users")
      .doc(user.uid)
      .set({
        "Username": user.displayName ,
        "Email": user.email ,
      }, SetOptions(merge: true));
}

  // ignore: use_build_context_synchronously
  Navigator.of(context).pushNamedAndRemoveUntil("HomePage", (route)=> false);
  }

    on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      Navigator.pushReplacementNamed(context, "SignUp");
      return;
    }

    print("Google Sign-In Error: $e");
  } on FirebaseAuthException catch (e) {
    print("Firebase Auth Error: ${e.code}");
  }
}

    Future<void> addUser(String uid) {
      return users.doc(uid).set({
            'Username': username.text, 
            'Email': email.text.trim(), 
          })
          // ignore: use_build_context_synchronously
          .then((value) => print("User Added Successfully"))
          // ignore: use_build_context_synchronously
          .catchError((error) => print("Failed to add user: $error")); 
    }

// ignore: non_constant_identifier_names
List Fields = 
  [

    {
      "Feild_Name" : "Name" ,
      "Icon_Name" : Icons.person_outline ,
      "hint_Text" : "Enter your Name" ,
    },

    {
      "Feild_Name" : "Email" ,
      "Icon_Name" : Icons.email_outlined ,
      "hint_Text" : "Enter your email" ,
    },

    {
      "Feild_Name" : "Password" ,
      "Icon_Name" : Icons.lock ,
      "hint_Text" : "Enter your password" ,
    }

  ];
  // ignore: non_constant_identifier_names
  GlobalKey<FormState> form_State = GlobalKey() ;
  
  @override
  void dispose()
  {
    super.dispose();
    username.dispose() ;
    email.dispose() ;
    password.dispose() ;
  }

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> controllers = 
  [
        username,
        email,
        password,
  ];
      return Scaffold(
      backgroundColor: const Color.fromARGB(235, 250, 244, 254),
        body: loading ? const Center(child: CircularProgressIndicator()) 
          :Form(
            autovalidateMode: AutovalidateMode.always,
            key: form_State, 
            child: ListView(
          children: 
          [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: 
              [
                Container(
                  width: 85 ,
                  height: 85 ,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                    colors: 
                    [
                    Color(0xFF7F00FF),
                    Color(0xFF00C6FF),
                    ],
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(60)) ,
                    border: Border.all(width: 3, color: const Color.fromARGB(236, 217, 232, 244))
                  ),
                  child: const Icon(
                    Icons.person ,
                    color: Color.fromARGB(225, 230, 213, 252) ,
                    size: 65,
                    ),
                ),

                const Text(
                "Sign Up" , 
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30 , 
                  fontWeight: FontWeight(450)
                  )
                  ),

                  const SizedBox(height: 5) ,
              ],
            ),

            ...List.generate(
              Fields.length, (i) {
                return Signup(
                  field: Fields[i] , 
                  controller: controllers[i] ,
                  );
              },
              ),
            
            Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                    colors: 
                    [
                    Color(0xFF7F00FF),
                    Color(0xFF00C6FF),
                    ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(25))
            ),
            child: MaterialButton(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              height: 60,
              textColor: Colors.white,
              onPressed: () async {
                if(form_State.currentState!.validate())
                {

                try {
                      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email.text.trim(),
                      password: password.text,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please Wait Seconds"))
                  );

                    setState(() {
                      loading = true ;
                    });

                  await addUser(credential.user!.uid) ;

                  await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                
                  if (!mounted) return;

                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.rightSlide,
                    title: 'Message',
                    desc: 'A verification email has been sent to your Gmail. Please verify your account.',
                    btnOkOnPress: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                    "LogIn",
                    (route) => false,
                    );
                  },
                  ).show();

                } 
                on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('The password provided is too weak.'))
                      );
                      return ;
                      } 
                    else if (e.code == 'email-already-in-use') {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('The account already exists for that email.'))
                      );
                      return ;
                      }
                    } catch (e) {
                        print(e);
                    }
                    
                  print("Valid");
                }
                else
                {
                  print("Not Valid");
                }
              },
              child: const Text("Sign Up" , style: TextStyle(fontSize: 25)),
              )
            ),

            const SizedBox(height: 25) ,

            Row(
              children: 
              [
                const SizedBox(width: 30) ,

                Container(
                  width: 100,
                  height: 2,
                  color: Colors.grey,
                ),

                const Text(" or continue with " , style: TextStyle(
                  fontSize: 17 ,
                  fontWeight: FontWeight(350) ,
                )
                ),

                Container(
                  width: 100,
                  height: 2,
                  color: Colors.grey,
                ),

              ],
            ),

            const SizedBox(height: 15) ,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: 
              [

                Container(
                  width: 70 ,
                  height: 70 ,
                  decoration: BoxDecoration(
                  color: const Color.fromRGBO(251, 250, 252, 1) ,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color.fromRGBO(212, 202, 234, 1)) ,
                  ),
                  child: MaterialButton(
                    color: const Color.fromRGBO(251, 250, 252, 1) ,
                    shape: const CircleBorder(),
                    onPressed: () {
                      signInWithGoogle() ;
                    },
                    child: Image.asset("My_photos/Google Icon.png"),
                    ),
                  ),
                  
                Container(
                  width: 70 ,
                  height: 70 ,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(251, 250, 252, 1) ,
                    borderRadius: const BorderRadius.all(Radius.circular(50)) ,
                    border: Border.all(color: const Color.fromRGBO(212, 202, 234, 1)) ,
                  ),
                child: IconButton(
                  onPressed: () {
                    signInWithFacebook() ;
                  }, 
                  icon: const Icon(Icons.facebook , color: Color.fromRGBO(91, 115, 234, 1) , size: 50)) ,
                ),

              ],
            ),
              
            const SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 50),
                const Text("Already have an account? " , style: TextStyle(
                  fontSize: 20 ,
                  fontWeight: FontWeight(450) ,
                )
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "LogIn");
                  },
                  child: const Text(" log In > " , 
                  style: TextStyle(
                  fontSize: 20 ,
                  fontWeight: FontWeight(450) ,                  
                  color: Color(0xFF5B73EA)
                )
                )
                )
              ],
            )
            
        
          ],
        )
        )
    );


  }
  
}