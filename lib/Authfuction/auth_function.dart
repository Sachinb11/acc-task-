/*

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/Home.dart';
import '../login/register.dart';
import 'firebasefuction.dart';


   signup(String email, String username,String mobile, String password,) async {
     try {
       UserCredential userCredential = await FirebaseAuth.instance
           .createUserWithEmailAndPassword(email: email, password: password);

       await FirebaseAuth.instance.currentUser!.updateDisplayName(username);
       await FirebaseAuth.instance.currentUser!.updateEmail(email);
       await FirestoreServices.saveUser(email,username,mobile,  userCredential.user!.uid);
       ScaffoldMessenger.of(context)
           .showSnackBar(SnackBar(content: Text('Registration Successful')));
       clear();
       Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginPage()));
       print('/////// Success ////////');
     } on FirebaseAuthException catch (e) {
       if (e.code == 'weak-password') {
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Password Provided is too weak')));
         print('The password provided is too weak.');
       } else if (e.code == 'email-already-in-use') {
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Email Provided already Exists')));
         print('The account already exists for that email.');
       }
     } catch (e) {
       print(e);
     }
   }

   signin(String email, password) async {
     try {
       UserCredential userCredential = await FirebaseAuth.instance
           .signInWithEmailAndPassword(email: email, password: password);
       print('/////// Success ////////');

       Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomePage()));
       ScaffoldMessenger.of(context)
           .showSnackBar(SnackBar(content: Text('You are Logged in')));

     } on FirebaseAuthException catch (e) {
       if (e.code == 'user-not-found') {
         ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('No user Found with this Email')));
         print('No user found for that email.');
       } else if (e.code == 'wrong-password') {
         ScaffoldMessenger.of(context)
             .showSnackBar(SnackBar(content: Text('Password did not match')));
         print('Wrong password provided for that user.');
       }
     }
   }


*/
