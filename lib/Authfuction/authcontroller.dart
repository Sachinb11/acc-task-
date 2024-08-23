import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../Home/home_page.dart';
import '../login/login.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  late Rx<User?> _user;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  void _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() =>  LoginPage());
    } else {
      Get.offAll(() =>  HomePage());
    }
  }

  void register(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar('Registration Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar('Login Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void signOut() async {
    await auth.signOut();
  }
}
