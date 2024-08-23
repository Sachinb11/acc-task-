import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'HomeController.dart';
import 'comment_modal.dart';
import 'post_model.dart';
import 'userprofile.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final HomeController homeController = Get.find();

  PostCard({required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _commentController = TextEditingController();
  bool _showMore = false;
  final int _commentLimit = 2;
  late Future<UserProfile> _userProfileFuture;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserProfile(widget.post.userId);
    if (widget.post.mediaType == 'video' && widget.post.mediaUrl != null) {
      _videoController = VideoPlayerController.network(widget.post.mediaUrl!)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<UserProfile> _fetchUserProfile(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        return UserProfile.fromDocument(snapshot);
      } else {
        throw Exception('User profile not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user profile: $e');
      return UserProfile(name: 'Unknown', email: '', photoUrl: '');
    }
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final newComment = Comment(
        username: FirebaseAuth.instance.currentUser?.email ?? 'Anonymous',
        content: _commentController.text,
      );
      try {
        await widget.homeController.addComment(widget.post.id, newComment);
        _commentController.clear();
      } catch (e) {
        Get.snackbar('Error', 'Failed to add comment: $e');
      }
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController != null) {
        if (_isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
        _isPlaying = !_isPlaying;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final commentsToShow = _showMore ? post.comments : post.comments.take(_commentLimit).toList();
    final user = FirebaseAuth.instance.currentUser;

    return Card(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<UserProfile>(
            future: _userProfileFuture,
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
                      widget.homeController.deletePost(post.id);
                    },
                  )
                      : null,
                );
              }
            },
          ),
          if (post.mediaUrl != null)
            post.mediaType == 'image'
                ? Center(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 300,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Image.network(
                  post.mediaUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            )
                : _videoController != null && _videoController!.value.isInitialized
                ? Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ],
            )
                : Center(
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.content, style: TextStyle(color: Colors.white)),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up, color: Colors.white),
                onPressed: () {
                  widget.homeController.likePost(post.id);
                },
              ),
              IconButton(
                icon: Icon(Icons.thumb_down, color: Colors.white),
                onPressed: () {
                  widget.homeController.unlikePost(post.id);
                },
              ),
              IconButton(
                icon: Icon(Icons.comment, color: Colors.white),
                onPressed: () {
                  _showCommentDialog();
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              final updatedPost = widget.homeController.posts.firstWhere(
                    (p) => p.id == post.id,
                orElse: () => post,
              );
              return Text('Likes: ${updatedPost.likes}', style: TextStyle(color: Colors.white));
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...commentsToShow.map((comment) {
                  return Text('${comment.username}: ${comment.content}', style: TextStyle(color: Colors.white));
                }).toList(),
                if (post.comments.length > _commentLimit)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showMore = !_showMore;
                      });
                    },
                    child: Text(_showMore ? 'Show less' : 'View more', style: TextStyle(color: Colors.blue)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.white54, width: 2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Comment',
                  style: TextStyle(color: Colors.pink, fontSize: 18.0),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Enter your comment',
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _addComment();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}

