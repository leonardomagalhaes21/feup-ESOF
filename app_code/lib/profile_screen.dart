import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'message_screen.dart';
import 'dart:io';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _biographyController;
  String _profileImageUrl = '';
  final ImagePicker _imagePicker = ImagePicker();
  User? _currentUser;

  final GlobalKey _avatarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _biographyController = TextEditingController();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      loadUserProfile(); 
    } else {
    }
  }

  Future<void> loadUserProfile() async {
    try {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid) 
          .get();
      setState(() {
        _nameController.text = userProfile['name'] ?? '';
        _biographyController.text = userProfile['biography'] ?? '';
        _profileImageUrl = userProfile['profileImageUrl'] ?? '';
      });
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> saveProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid) 
          .set({
        'name': _nameController.text.trim(),
        'biography': _biographyController.text.trim(),
        'profileImageUrl': _profileImageUrl,
      });

      print('User profile updated successfully!');
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  Future<void> uploadImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    List<int> imageBytes = await image.readAsBytes();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'profileImageBytes': imageBytes,
      });

      setState(() {
        _profileImageUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      });

      if (_avatarKey.currentState != null) {
        (_avatarKey.currentState as State).setState(() {});
      }

      print('Image uploaded successfully!');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    key: _avatarKey,
                    radius: 50,
                    backgroundImage: _profileImageUrl.isNotEmpty
                        ? NetworkImage(_profileImageUrl)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: uploadImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _biographyController,
              decoration: InputDecoration(labelText: 'Biography'),
              maxLines: null,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveProfile,
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPublicationScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.message),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessageScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}