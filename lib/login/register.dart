import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../Authfuction/firebasefuction.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  bool passwordVisible = true;

  final colorizeColors = [
    Colors.pink,
    Colors.white,
    Colors.pink,
    Colors.white,
  ];

  final colorizeTextStyle = TextStyle(
      fontSize: 40.0,
      fontFamily: 'Horizon',
      fontWeight: FontWeight.w400
  );

  void clear() {
    emailController.clear();
    passController.clear();
    usernameController.clear();
    mobileController.clear();
  }

  void signup(String email, String username, String mobile, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(username);
        await user.updateEmail(email);

        // Save user details to Firestore
        await FirestoreServices().saveUser(email, username, mobile, password, user.uid);

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Registration Successful')));
        clear();
        Get.offAll(() =>  LoginPage());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password Provided is too weak')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email Provided already Exists')));
      }
    } catch (e) {
      print(e);
    } finally {
      Navigator.of(context).pop(); // close the progress dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.dstOver),
            image: const AssetImage("assets/images/img.png"),
            fit: BoxFit.cover,
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 130,),
                AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Register Here...',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                    ),
                  ],
                  isRepeatingAnimation: true,
                  onTap: () {
                    print("Tap Event");
                  },
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    cursorColor: Colors.pink,
                    controller: usernameController,
                    style: const TextStyle(color: Colors.pink),
                    validator: (username) {
                      if (username!.isNotEmpty) {
                        return null;
                      } else {
                        return 'Please Enter username';
                      }
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Colors.pink,),
                        hintText: "Enter UserName",
                        hintStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black54)
                        ),
                        filled: true,
                        fillColor: Colors.black54,
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15, top: 15, bottom: 0),
                  child: TextFormField(
                    cursorColor: Colors.pink,
                    controller: mobileController,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.pink),
                    validator: (mobile) {
                      if (mobile!.isEmpty && mobile.length <= 10) {
                        return 'Please Enter valid mobile number';
                      } else if (!RegExp(pattern).hasMatch(mobile)) {
                        return 'Please Enter valid mobile number only 10 digit';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone, color: Colors.pink,),
                        hintText: "Enter Mobile Number",
                        hintStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black54)
                        ),
                        filled: true,
                        fillColor: Colors.black54,
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    cursorColor: Colors.pink,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.pink),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a valid Email';
                      }
                      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
                        return 'Please enter a valid Email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email, color: Colors.pink,),
                        hintText: "Enter Email",
                        hintStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black54)
                        ),
                        filled: true,
                        fillColor: Colors.black54,
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    cursorColor: Colors.pink,
                    controller: passController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: passwordVisible,
                    validator: (password) {
                      if (password!.isNotEmpty) {
                        return null;
                      } else {
                        return 'Please enter password';
                      }
                    },
                    style: const TextStyle(color: Colors.pink),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password, color: Colors.pink,),
                        suffixIcon: IconButton(
                          icon: Icon(
                              passwordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.pink),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                        hintText: "Enter Password",
                        hintStyle: const TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black54)
                        ),
                        filled: true,
                        fillColor: Colors.black54,
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.91,
                  height: 60,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll(Colors.pink),
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          signup(emailController.text.toString(), usernameController.text.toString(), mobileController.text.toString(), passController.text.toString());
                        }
                      }, child: const Text("Register", style: TextStyle(color: Colors.white))),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an Account?", style: TextStyle(color: Colors.white),),
                    TextButton(onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                    }, child: const Text("Sign In",
                      style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 18),))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
