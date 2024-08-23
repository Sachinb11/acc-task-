import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Home/home_page.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
  }

  void signin(String email, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage()));

      clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are Logged in')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user Found with this Email')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Password did not match')));
      }
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
                      'Login Here..',
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
                      if ((password)!.isNotEmpty) {
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
                          backgroundColor: const WidgetStatePropertyAll(Colors.pink),
                          shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          signin(emailController.text.toString(), passController.text.toString());
                        }
                      }, child: const Text("Login", style: TextStyle(color: Colors.white))),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Not have an Account?", style: TextStyle(color: Colors.white),),
                    TextButton(onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                    }, child: const Text("Sign Up",
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
