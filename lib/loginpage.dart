import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget
{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => StateLoginPage();

}

class StateLoginPage extends State<LoginPage>
{
  TextEditingController email = TextEditingController() ;
  TextEditingController password = TextEditingController() ;
  bool loading = false ;

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
      Navigator.pushReplacementNamed(context, "LogIn");
      return;
    }
    print("Google Sign-In Error: $e");
  } on FirebaseAuthException catch (e) {
    print("Firebase Auth Error: ${e.code}");
  }
}

  // ignore: non_constant_identifier_names
  GlobalKey<FormState> form_State = GlobalKey() ;

  @override
  void dispose ()
  {
    super.dispose() ;
    email.dispose() ;
    password.dispose() ;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(235, 250, 244, 254),
        body: Form(
        autovalidateMode: AutovalidateMode.always ,
        key: form_State ,
        child: loading ? const Center(child: CircularProgressIndicator())
          :ListView(
          children: 
          [

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: 
              [
                Container(
                  width: 85 ,
                  height: 85 ,
                  margin: const EdgeInsets.only(top: 30),
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
                "Login" , 
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30 , 
                  fontWeight: FontWeight(450)
                  )
                  ),

                  const SizedBox(height: 25) ,
              ],
            ),

              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: 
              [
                
                const Padding(
                  padding: EdgeInsets.only(left: 20) ,
                  child: Text("Email" , style: TextStyle(
                  color: Colors.black,
                  fontSize: 25 , 
                  fontWeight: FontWeight(375) ,       
                ))),

                InkWell(
                  onTap: () async
                  {
                    
                    if(email.text=="")
                    {
                      AwesomeDialog(
                          dismissOnBackKeyPress: true,
                          dismissOnTouchOutside: true,
                          // ignore: use_build_context_synchronously
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Error',
                          desc: 'The Email Field is Empty Please Enter Your Email',
                          ).show(); 
                          return ;
                    }

                      final resultOfEmail = await FirebaseFirestore.instance
                        .collection("Users").where("Email" , isEqualTo: email.text.trim()).get() ;

                        if(resultOfEmail.docs.isEmpty)
                        {
                          AwesomeDialog(
                          dismissOnBackKeyPress: true,
                          dismissOnTouchOutside: true,
                          // ignore: use_build_context_synchronously
                          context: context,
                          dialogType: DialogType.warning,
                          animType: AnimType.rightSlide,
                          title: 'Warning',
                          desc: 'The Email is not Exist Please Enter your Correct Email',
                          ).show();
                        }

                      else 
                      {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text) ;
                      AwesomeDialog(
                          dismissOnBackKeyPress: true,
                          dismissOnTouchOutside: true,
                          // ignore: use_build_context_synchronously
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.rightSlide,
                          title: 'Message',
                          desc: 'a message Has been Sent to your Gmail to assign New Password',
                          ).show();
                    }

                    },

                  child: const Padding(
                  padding: EdgeInsets.only(right: 15) ,
                  child: Text("Forgot password?" , style: TextStyle(
                  color: Color(0xFF9094C4) ,
                  fontSize: 17
                )))
                )
              ],
            ),
          
            const SizedBox(height: 15),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
              validator: (value) 
              {

                if (value == null || value.isEmpty) 
                {
                    return "The field can't be empty";
                }

                final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return "Please enter a valid email";
      }
      return null;

              },
              controller: email ,
              keyboardType: TextInputType.emailAddress ,
              decoration: const InputDecoration(
                fillColor: Color(0xFFFBF9FC),
                filled: true,
                prefixIcon: Icon(Icons.email_outlined , size: 30, color: Color.fromRGBO(119, 115, 134, 1)),
                contentPadding: EdgeInsets.all(18) ,
                hintText: "Enter your email " ,
                hintStyle: TextStyle(color: Colors.grey , fontSize: 20) ,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)) ,
                    borderSide: BorderSide.none ,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)) ,
                  borderSide: BorderSide.none ,
                )
              ),
            ),
            ),

            const SizedBox(height: 30),

            const Padding(
              padding: EdgeInsetsGeometry.only(left: 20),
              child: Text("Password" , style: TextStyle(
                  color: Colors.black,
                  fontSize: 25 , 
                  fontWeight: FontWeight(375) ,       
                )
                ), 
            ),

            const SizedBox(height: 15),

              Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: password,
                validator: (value) 
                {
                  if (value == null || value.isEmpty) 
                  {
                      return "The field can't be empty";
                  }

                  if (value.length < 8) 
                  {
                      return "Password must be at least 8 characters";
                  }

                  if (value.length > 12) 
                  {
                      return "Password must be less than 13 characters";
                  }
                  return null;

                },
                obscureText: true ,
                keyboardType: TextInputType.text ,
                decoration: const InputDecoration(
                fillColor: Color(0xFFFBF9FC),
                filled: true ,
                prefixIcon: Icon(Icons.lock, size: 30, color: Color.fromRGBO(119, 115, 134, 1)),
                contentPadding: EdgeInsets.all(18) ,
                hintText: "Enter your password" ,
                hintStyle: TextStyle(color: Colors.grey , fontSize: 20) ,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)) ,
                    borderSide: BorderSide.none ,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)) ,
                  borderSide: BorderSide.none ,
                )
                ),
              ),
            ),

            const SizedBox(height: 50) ,

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
              gradient: const LinearGradient(
                    colors: 
                    [
                    Color(0xFF7F00FF),
                    Color(0xFF00C6FF),
                    ],
              ),
              borderRadius: BorderRadius.circular(25)
              ),

              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)
                ),
                height: 60,
                textColor: Colors.white,
                onPressed: () async {
                  
                  if(form_State.currentState!.validate())
                  {

                    try {
                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email.text.trim(),
                        password: password.text ,
                        );

                        if(credential.user!.emailVerified)
                        {
                          setState(() {
                            loading = true ;
                          });

                          await Future.delayed(const Duration(seconds: 2)) ;
                          
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            "HomePage" , 
                            (route) => false 
                            );
                        }

                        else
                        {
                          FirebaseAuth.instance.currentUser!.sendEmailVerification() ;
                          AwesomeDialog(
                          dismissOnBackKeyPress: true,
                          dismissOnTouchOutside: true,
                          // ignore: use_build_context_synchronously
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Warning',
                          desc: 'Your Email is not Verify Please Verify Your Email',
                          ).show();
                        }
                    } on FirebaseAuthException catch (e) {
                        if (e.code == 'invalid-credential') {

                        final resultOfEmail = await FirebaseFirestore.instance
                        .collection("Users").where("Email" , isEqualTo: email.text.trim()).get() ;

                        if(resultOfEmail.docs.isEmpty)
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("The Email is Not Exist"))
                          );
                        }

                        else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("The Password is Not True"))
                          ); 
                        }

                    } else {
                      print("e: $e");
                    }
                  }

                  }

                  else
                  {
                    print("Not Valid") ;
                  }


                },
                child: const Text(
                  "Log In" ,
                  style: TextStyle(fontSize: 20 , fontWeight: FontWeight.bold),
                  ),
                ),
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
                    onPressed: () {
                      signInWithGoogle() ;
                    },
                    color: const Color.fromRGBO(251, 250, 252, 1) ,
                    shape: const CircleBorder(),
                    
                    child: Image.asset("My_photos/Google Icon.png"),
                  )
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
              
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 50),
                const Text("Not registered yet?" , style: TextStyle(
                  fontSize: 20 ,
                  fontWeight: FontWeight(450) ,
                )
                ),
                InkWell(
                  onTap: () 
                  {
                    Navigator.of(context).pushNamed("SignUp") ;
                  },
                  child: const Text(" Sign Up > " , 
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