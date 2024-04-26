import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'dart:typed_data';
import 'message_screen.dart';
import 'login_screen.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _biographyController;
  String _profileImageUrl = '';
  final ImagePicker _imagePicker = ImagePicker();
  User? _currentUser;
  late Future<QuerySnapshot<Map<String, dynamic>>> _ratings;
  

  final GlobalKey _avatarKey = GlobalKey();

  @override
void initState() {
super.initState();
_nameController = TextEditingController();
_biographyController = TextEditingController();
_getCurrentUser();
_tabController = TabController(length: 2, vsync: this);
//_ratings = _getRatings();
}

@override
void dispose() {
_tabController.dispose();
super.dispose();
}



  Future<void> _getCurrentUser() async {
  _currentUser = FirebaseAuth.instance.currentUser;
  if (_currentUser != null) {
    setState(() {
      _profileImageUrl = '';
    });
    await loadUserProfile(); 
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
        var timestamp = DateFormat('yyyy-MM-dd HH:mm')
              .format(data['timestamp'].toDate());
          var publicationImageUrl = data['publicationImageUrl'] ?? '';
          var description = data['description'] ?? '';
          var title = data['title'] ?? '';
          var timestamp2 = DateFormat('yyyy-MM-dd HH:mm')
              .format(data['timestamp'].toDate());
          var publicationImageUrl2 = data['publicationImageUrl'] ?? '';
          var description2 = data['description'] ?? '';
          var title2 = data['title'] ?? '';
          
        if (imageUrl != null && imageUrl.isNotEmpty) {
          imageBytes = base64Decode(imageUrl.split(',').last);
        }

        Widget publicationWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FutureBuilder<ImageProvider?>(
                    future: decodeImage(_profileImageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                              ConnectionState.waiting ||
                          snapshot.data == null) {
                        return const CircularProgressIndicator();
                      }
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: snapshot.data!,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(_nameController.text),
                      
                      Text(
                        timestamp,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<ImageProvider?>(
                future: decodeImage(publicationImageUrl),
                builder:
                    (context, AsyncSnapshot<ImageProvider?> imageSnapshot) {
                  if (imageSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      imageSnapshot.data == null) {
                    return const CircularProgressIndicator();
                  }
                  double screenWidth = MediaQuery.of(context).size.width;
                  return Image(
                    image: imageSnapshot.data!,
                    width: screenWidth,
                    fit: BoxFit.contain,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(description),
              
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

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false, // Clear the stack
      );
    } catch (e) {
      print('Error signing out: $e');
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Profile'),
            Tab(text: 'Sales'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
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
                const SizedBox(height: 10),
    Center(
      child: Text(
        'Average Rating: ', // Add your average rating value here
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Logout'),
                  ),
                ),
              ],
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
                return ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: snapshot.data ?? [],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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

Future<ImageProvider?> decodeImage(String imageUrl) async {
    List<int> imageBytes = base64Decode(imageUrl.split(',').last);
    return MemoryImage(Uint8List.fromList(imageBytes));
  }