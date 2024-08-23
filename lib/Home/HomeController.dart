import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'comment_modal.dart';
import 'post_model.dart';

class HomeController extends GetxController {
  var posts = <Post>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      // Fetch all users
      QuerySnapshot userSnapshots = await FirebaseFirestore.instance.collection('users').get();
      var allPosts = <Post>[];

      print('Fetched ${userSnapshots.docs.length} users.');

      for (var userDoc in userSnapshots.docs) {
        print('User ID: ${userDoc.id}');

        var userData = userDoc.data() as Map<String, dynamic>? ?? {};
        var userPosts = userData['posts'] as List<dynamic>? ?? [];

        print('Found ${userPosts.length} posts for user ${userDoc.id}.');

        for (var postMap in userPosts) {
          try {
            print('Post Map: $postMap');
            var post = Post.fromMap(postMap as Map<String, dynamic>);
            print('Post ID: ${post.id}');
            allPosts.add(post);
          } catch (e) {
            print("Error converting post data to Post object: $e");
          }
        }
      }

      posts.assignAll(allPosts);

    } catch (e) {
      print("Error fetching posts from Firestore: $e");
    }
  }

  Future<void> createPost(Post post) async {
    try {
      // Generate a unique post ID based on the current timestamp
      String postId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new post object with the generated ID
      Post newPost = Post(
        id: postId,
        userId: post.userId,
        email: post.email,
        name: post.name,
        content: post.content,
        mediaUrl: post.mediaUrl,
        mediaType: post.mediaType,
        likes: post.likes,
        comments: post.comments,
        timestamp: DateTime.now().toIso8601String(), // Current timestamp in ISO format
        userProfileImageUrl: post.userProfileImageUrl,
      );

      // Convert the new post to a map for Firestore
      Map<String, dynamic> postMap = newPost.toMap();

      // Update Firestore
      var userDocRef = FirebaseFirestore.instance.collection('users').doc(newPost.userId);
      await userDocRef.update({
        'posts': FieldValue.arrayUnion([postMap]),
      });

      // Optionally, you might want to refresh the posts in your local state
      fetchPosts();

    } catch (e) {
      print("Error creating post: $e");
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      // Find the post to delete
      var postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        var post = posts[postIndex];
        // Remove the post from the local list
        posts.removeAt(postIndex);

        // Update Firestore
        var userDocRef = FirebaseFirestore.instance.collection('users').doc(post.userId);
        var userDoc = await userDocRef.get();
        if (userDoc.exists) {
          var userPosts = userDoc.data()?['posts'] as List<dynamic>? ?? [];
          userPosts.removeWhere((p) => (p as Map<String, dynamic>)['id'] == postId);
          await userDocRef.update({'posts': userPosts});
        }
      } else {
        print("Post with ID $postId not found in local list.");
      }
    } catch (e) {
      print("Error deleting post: $e");
    }
  }

  Future<void> likePost(String postId) async {
    try {
      var postIndex = posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        var post = posts[postIndex];
        post.likes += 1; // Increment the like count
        posts[postIndex] = post; // Update the list
        await _updatePostInFirestore(post); // Update Firestore
      } else {
        print("Post with ID $postId not found in local list.");
      }
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      var postIndex = posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        var post = posts[postIndex];
        post.likes -= 1; // Decrement the like count
        posts[postIndex] = post; // Update the list
        await _updatePostInFirestore(post); // Update Firestore
      } else {
        print("Post with ID $postId not found in local list.");
      }
    } catch (e) {
      print("Error unliking post: $e");
    }
  }

  Future<void> _updatePostInFirestore(Post post) async {
    try {
      // Get the user's document reference
      var userDocRef = FirebaseFirestore.instance.collection('users').doc(post.userId);
      var userDoc = await userDocRef.get();
      if (userDoc.exists) {
        // Retrieve posts list
        var userPosts = userDoc.data()?['posts'] as List<dynamic>? ?? [];

        // Update the specific post in the list
        var updatedPosts = userPosts.map((p) {
          if ((p as Map<String, dynamic>)['id'] == post.id) {
            return post.toMap(); // Replace with updated post data
          }
          return p;
        }).toList();

        // Update the user's document with the updated posts list
        await userDocRef.update({'posts': updatedPosts});
      } else {
        print("User with ID ${post.userId} not found.");
      }
    } catch (e) {
      print("Error updating post in Firestore: $e");
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      var postIndex = posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        var post = posts[postIndex];
        post.comments.add(comment);
        posts[postIndex] = post; // Update the local list
        await _updatePostInFirestore(post); // Update Firestore
      } else {
        print("Post with ID $postId not found in local list.");
      }
    } catch (e) {
      print("Error adding comment: $e");
    }
  }
}
