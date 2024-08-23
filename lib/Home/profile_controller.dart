import 'package:acc_task/Home/userprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'post_model.dart'; // Import your post model

class ProfileController extends GetxController {
  var userProfile = Rxn<UserProfile>();
  var userPosts = <Post>[].obs; // List to hold user posts
  var imagePosts = <Post>[].obs;
  var videoPosts = <Post>[].obs;


  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    fetchPosts(); // Fetch posts when the controller is initialized
  }

  void fetchUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        userProfile.value = UserProfile.fromDocument(snapshot);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(profile.toJson());
        fetchUserProfile();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    }
  }

  Future<void> fetchPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch user data
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userData = userSnapshot.data() as Map<String, dynamic>?;
        print("User Data:");
        print(userData);

        if (userData == null || !userData.containsKey('posts')) {
          print("No posts found for this user.");
          return;
        }

        // Extract posts from user data
        List<dynamic> posts = userData['posts'];
        List<Post> imagePostsList = [];
        List<Post> videoPostsList = [];

        for (var postData in posts) {
          final post = Post.fromMap(postData as Map<String, dynamic>);
          if (post.mediaType == 'image') {
            imagePostsList.add(post);
          } else if (post.mediaType == 'video') {
            videoPostsList.add(post);
          }
        }

        imagePosts.value = imagePostsList;
        videoPosts.value = videoPostsList;
        print("imagePosts1111");
        print(imagePosts.value);
        print(videoPosts.value);

      } catch (e) {
        print("Error fetching posts: $e");
      }
    }
  }


}
