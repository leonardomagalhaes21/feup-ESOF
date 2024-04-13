import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'dart:typed_data';
import 'message_screen.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
    } else {}
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

  Future<List<Widget>> loadUserPublications() async {
  try {
    QuerySnapshot publicationsSnapshot = await FirebaseFirestore.instance
        .collection('publications')
        .where('userId', isEqualTo: _currentUser!.uid)
        .get();

    List<Widget> publicationWidgets = [];
    for (DocumentSnapshot doc in publicationsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<int> imageBytes = [];
      String? imageUrl = data['publicationImageUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageBytes = base64Decode(imageUrl.split(',').last);
      }

      Widget publicationWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_nameController.text),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10), 
          Image.memory(
            Uint8List.fromList(imageBytes),
            width: double.infinity, 
            fit: BoxFit.contain, 
          ),
          const SizedBox(height: 10),
          Text(
            '${_nameController.text}: ${data['description'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50), 
        ],
      );
      publicationWidgets.add(publicationWidget);
    }
    return publicationWidgets;
  } catch (e) {
    print('Error loading user publications: $e');
    return [];
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
        _profileImageUrl =
            'data:image/jpeg;base64,${base64Encode(imageBytes)}';
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
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: const Padding(
                padding: EdgeInsets.only(
                  bottom: 4.0,
                ),
                child: Text(
                  'FEUP-reUSE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 39.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              height: 4,
              color: Colors.black,
            ),
          ],
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _biographyController,
              decoration: const InputDecoration(labelText: 'Biography'),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text('Save'),
              ),
            ),
            FutureBuilder(
              future: loadUserPublications(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot.data ?? [],
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddPublicationScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MessageScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
