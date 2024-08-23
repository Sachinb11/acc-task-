import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class AddPostModal extends StatefulWidget {
  @override
  _AddPostModalState createState() => _AddPostModalState();
}

class _AddPostModalState extends State<AddPostModal> {
  final TextEditingController _postController = TextEditingController();
  XFile? _imageFile;
  XFile? _videoFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _videoFile = pickedFile;
    });
  }

  void _submitPost() {
    final text = _postController.text;
    // Handle the post submission logic
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Write something...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            if (_imageFile != null)
              Image.file(File(_imageFile!.path), height: 100, width: 100, fit: BoxFit.cover),
            if (_videoFile != null)
              Container(
                height: 100,
                width: 100,
                color: Colors.grey,
                child: Center(child: Icon(Icons.video_library)),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Add Image'),
            ),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('Add Video'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
