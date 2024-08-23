import 'dart:io';
import 'package:acc_task/Home/post_model.dart';
import 'package:acc_task/Home/profile_controller.dart';
import 'package:acc_task/Home/userprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController profileController = Get.put(ProfileController());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _newDisplayName;
  User? user;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileController.fetchPosts();
    print("jfnskjd");
    print(profileController.imagePosts.value);
    user = FirebaseAuth.instance.currentUser;

}
  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final userProfile = profileController.userProfile.value;

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : userProfile?.photoUrl != null
                        ? NetworkImage(userProfile!.photoUrl!)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: _showEditProfileDialog,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            _newDisplayName ?? userProfile?.name ?? 'Username',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Implement follow functionality
                              },
                              child: Text(
                                'Follow',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Implement following functionality
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink),
                              child: Text(
                                'Following',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Colors.pink,
                      tabs: [
                        Tab(
                          text: 'Images',
                          icon: Icon(Icons.image, color: Colors.white),
                        ),
                        Tab(
                          text: 'Videos',
                          icon: Icon(Icons.video_library, color: Colors.white),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Existing image grid
                          Obx(() {
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: profileController.imagePosts.length,
                              itemBuilder: (context, index) {
                                final post = profileController.imagePosts[index];
                                return GestureDetector(
                                  onTap: () {
                                    _showPostDetails(context, post);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 1.0),
                                    ),
                                    child: GridTile(
                                      child: post.mediaUrl != null
                                          ? Image.network(post.mediaUrl!, fit: BoxFit.cover)
                                          : Container(color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          // Videos grid
                          Obx(() {
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: profileController.videoPosts.length,
                              itemBuilder: (context, index) {
                                final post = profileController.videoPosts[index];
                                return GestureDetector(
                                  onTap: () {
                                    _showPostDetails(context, post);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 1.0),
                                    ),
                                    child: GridTile(
                                      child: post.mediaUrl != null
                                          ? VideoPlayerWidget(videoUrl: post.mediaUrl!)
                                          : Container(color: Colors.grey),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )



          ],
        );
      }),
    );
  }


  void _showPostDetails(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            int initialCommentCount = 2; // Number of comments to initially display

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: Colors.white54, width: 1.0), // White border
              ),
              backgroundColor: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<UserProfile>(
                      future: _fetchUserProfile(post.userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                            ),
                            title: Text('Loading...', style: TextStyle(color: Colors.white)),
                          );
                        } else if (snapshot.hasError) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                            ),
                            title: Text('Error loading profile', style: TextStyle(color: Colors.white)),
                          );
                        } else if (!snapshot.hasData) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                            ),
                            title: Text('Profile not found', style: TextStyle(color: Colors.white)),
                          );
                        } else {
                          final userProfile = snapshot.data!;
                          return ListTile(
                            leading: userProfile.photoUrl != null
                                ? CircleAvatar(
                              backgroundImage: NetworkImage(userProfile.photoUrl!),
                            )
                                : CircleAvatar(
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(userProfile.name, style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                              post.timestamp != null ? post.timestamp.toString() : '',
                              style: TextStyle(color: Colors.white54),
                            ),
                            trailing: user?.uid == post.userId
                                ? IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                _deletePost(post.id); // Call _deletePost
                              },
                            )
                                : null,
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.white54), // White54 divider
                    SizedBox(height: 10),
                    post.mediaUrl != null
                        ? post.mediaType == 'video'
                        ? Container(
                      width: double.infinity,
                      height: 200,
                      child: VideoPlayerWidget(videoUrl: post.mediaUrl!),
                    )
                        : Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(post.mediaUrl!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )
                        : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey,
                      child: Center(child: Text('No media available', style: TextStyle(color: Colors.white))),
                    ),
                    SizedBox(height: 10),
                    Text(post.content, style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    Divider(color: Colors.white54), // White54 divider
                    SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up, color: Colors.pink), // Pink like icon
                          onPressed: () {
                            // Implement like functionality
                          },
                        ),
                        Text(
                          '${post.likes}',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.comment, color: Colors.pink), // Pink comment icon
                          onPressed: () {
                            _showCommentDialog(context, post); // Implement _showCommentDialog
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Display comments
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...post.comments.take(initialCommentCount).map((comment) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '${comment.username}: ${comment.content}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            // Show "View More" button if there are more comments to show
                            if (post.comments.length > initialCommentCount)
                              TextButton(
                                onPressed: () {
                                  _showCommentDialog(context, post); // Open comment dialog with all comments
                                },
                                child: Text(
                                  'View More',
                                  style: TextStyle(color: Colors.pink),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCommentDialog(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.white54, width: 1.0), // White border
          ),
          backgroundColor: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comments', style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: post.comments.map((comment) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '${comment.username}: ${comment.content}',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


// Example method to delete a post
  void _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      print('Post deleted successfully');
      // Optionally, refresh the UI or show a success message
    } catch (e) {
      print('Error deleting post: $e');
      // Optionally, show an error message
    }
  }

/*
// Example method to show comments dialog
  void _showCommentDialog(BuildContext context, Post post) {
    // State to manage whether to show all comments or a limited number
    bool showAllComments = false;
    // Number of comments to initially display
    int initialCommentCount = 5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.black,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black, // Ensure the background is black
                  border: Border.all(color: Colors.white54, width: 1.0), // White54 border
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                padding: const EdgeInsets.all(16.0),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5, // Adjust max height as needed
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Comments:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    // Display comments with padding and scroll if needed
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...post.comments.take(showAllComments ? post.comments.length : initialCommentCount).map((comment) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '${comment.username}: ${comment.content}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            // Show "View More" button if there are more comments to show
                            if (post.comments.length > initialCommentCount && !showAllComments)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    showAllComments = true;
                                  });
                                },
                                child: Text(
                                  'View More',
                                  style: TextStyle(color: Colors.pink),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
*/



  Future<UserProfile> _fetchUserProfile(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Check if the document exists
      if (snapshot.exists) {
        // Convert DocumentSnapshot to UserProfile using fromDocument
        return UserProfile.fromDocument(snapshot);
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      // Show an error message using Get.snackbar
      Get.snackbar('Error', 'Failed to load user profile: $e');
      // Return a default UserProfile or handle as needed
      return UserProfile(name: 'Unknown', email: '', photoUrl: '');
    }
  }


  Future<void> _showEditProfileDialog() async {
    final User? user = _auth.currentUser;
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double dialogHeight = screenHeight * 0.4;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Colors.white54, width: 2.0),
              ),
              title: Text('Edit Profile', style: TextStyle(color: Colors.pink)),
              content: Container(
                height: dialogHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(setState),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter new display name',
                        hintStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        _newDisplayName = value;
                      },
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
              actions: [
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else ...[
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        if (user != null) {
                          String? photoUrl;

                          if (_imageFile != null) {
                            final storageRef = FirebaseStorage.instance
                                .ref()
                                .child('profile_pictures/${user.uid}.jpg');
                            final uploadTask = storageRef.putFile(_imageFile!);
                            final snapshot = await uploadTask.whenComplete(() {});
                            photoUrl = await snapshot.ref.getDownloadURL();
                            await user.updatePhotoURL(photoUrl);
                          } else {
                            photoUrl = user.photoURL;
                          }

                          if (_newDisplayName != null) {
                            await user.updateProfile(displayName: _newDisplayName);
                          }

                          final updatedProfile = UserProfile(
                            name: _newDisplayName ?? user.displayName!,
                            email: user.email!,
                            photoUrl: photoUrl,
                          );

                          await profileController.updateUserProfile(updatedProfile);
                          await user.reload();
                          profileController.fetchUserProfile();
                        }
                      } catch (e) {
                        print("Error updating profile: $e");
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Save', style: TextStyle(color: Colors.pink)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.pink)),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showImageSourceDialog(StateSetter setState) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Select Image Source', style: TextStyle(color: Colors.pink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.pink),
                title: Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, setState);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.pink),
                title: Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, setState);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, StateSetter setState) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
