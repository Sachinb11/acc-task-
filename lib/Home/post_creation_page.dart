import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomeController.dart';
import 'home_page.dart';
import 'post_model.dart';
import 'package:intl/intl.dart';

class PostCreationPage extends StatefulWidget {
  @override
  _PostCreationPageState createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final TextEditingController _contentController = TextEditingController();
  File? _mediaFile;
  String _mediaType = '';
  final HomeController homeController = Get.find();
  bool _isLoading = false;

  Future<void> _pickMedia(bool isImage) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        side: BorderSide(color: Colors.white.withOpacity(0.54), width: 1),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera, color: Colors.pink),
                title: Text('Camera', style: TextStyle(color: Colors.pink)),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await (isImage
                      ? ImagePicker().pickImage(source: ImageSource.camera)
                      : ImagePicker().pickVideo(source: ImageSource.camera));
                  if (pickedFile != null) {
                    setState(() {
                      _mediaFile = File(pickedFile.path);
                      _mediaType = isImage ? 'image' : 'video';
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.pink),
                title: Text('Gallery', style: TextStyle(color: Colors.pink)),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await (isImage
                      ? ImagePicker().pickImage(source: ImageSource.gallery)
                      : ImagePicker().pickVideo(source: ImageSource.gallery));
                  if (pickedFile != null) {
                    setState(() {
                      _mediaFile = File(pickedFile.path);
                      _mediaType = isImage ? 'image' : 'video';
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _cancelMedia() {
    setState(() {
      _mediaFile = null;
      _mediaType = '';
    });
  }

  Future<void> _createPost() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? mediaUrl;
      try {
        if (_mediaFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('post_media')
              .child('${DateTime.now().millisecondsSinceEpoch}.${_mediaType == 'image' ? 'jpg' : 'mp4'}');
          await storageRef.putFile(_mediaFile!);
          mediaUrl = await storageRef.getDownloadURL();
        }

        DateTime now = DateTime.now();
        String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

        final post = Post(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: _contentController.text,
          userId: user.uid,
          email: user.email!,
          name: user.displayName!,
          mediaUrl: mediaUrl,
          mediaType: _mediaType,
          likes: 0,
          comments: [],
          timestamp: formattedDateTime,
        );

        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (userDoc.exists) {
          List<dynamic> existingPosts = userDoc.data()?['posts'] ?? [];
          existingPosts.add(post.toMap());
          await userDocRef.update({'posts': existingPosts});
        } else {
          await userDocRef.set({
            'posts': [post.toMap()],
          });
        }

        Get.snackbar(
          'Success',
          'Post created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        await Future.delayed(Duration(seconds: 2));
        Get.offAll(() => HomePage());
      } catch (e) {
        Get.snackbar('Error', 'Failed to create post');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'User not authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      hintText: 'Write something...',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  if (_mediaFile != null)
                    Stack(
                      children: [
                        _mediaType == 'image'
                            ? Container(
                          constraints: BoxConstraints(
                            maxHeight: 300, // Adjust the height as needed
                          ),
                          child: Image.file(_mediaFile!, fit: BoxFit.cover),
                        )
                            : Container(
                          height: 200,
                          child: Center(
                            child: Text('Video Selected', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red, size: 30),
                            onPressed: _cancelMedia,
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo, color: Colors.white),
                        onPressed: () => _pickMedia(true),
                      ),
                      IconButton(
                        icon: Icon(Icons.video_library, color: Colors.white),
                        onPressed: () => _pickMedia(false),
                      ),
                      Spacer(),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.pink),
                        ),
                        onPressed: _isLoading ? null : _createPost,
                        child: Text('Post', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Colors.pink,
              ),
            ),
        ],
      ),
    );
  }
}
