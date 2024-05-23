import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'message_screen.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _biographyController;
  String _profileImageUrl = '';
  String _newProfileImageUrl = '';
  final ImagePicker _imagePicker = ImagePicker();
  User? _currentUser;
  late Future<QuerySnapshot<Map<String, dynamic>>> _ratings;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _biographyController = TextEditingController();
    _getCurrentUser();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double _calculateAverageRating(QuerySnapshot<Map<String, dynamic>> ratingsSnapshot) {
    if (ratingsSnapshot.size == 0) {
      return 0.0;
    }
    
    double totalRating = 0;
    for (var ratingDoc in ratingsSnapshot.docs) {
      totalRating += ratingDoc.data()['rating'];
    }
    return totalRating / ratingsSnapshot.size;
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

        String? imageUrl = data['publicationImageUrl'];
        var timestamp = DateFormat('yyyy-MM-dd HH:mm').format(data['timestamp'].toDate());
        var description = data['description'] ?? '';
        var title = data['title'] ?? '';

        Widget publicationWidget = Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await deletePublication(doc.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FutureBuilder<ImageProvider?>(
                    future: decodeImage(_profileImageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.data == null) {
                        return const CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                        );
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
                future: decodeImage(imageUrl),
                builder: (context, AsyncSnapshot<ImageProvider?> imageSnapshot) {
                  if (imageSnapshot.connectionState == ConnectionState.waiting || imageSnapshot.data == null) {
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
          ),
        );
        publicationWidgets.add(publicationWidget);
      }
      return publicationWidgets;
    } catch (e) {
      print('Error loading user publications: $e');
      return [];
    }
  }

  Future<void> deletePublication(String publicationId) async {
    try {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this publication?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await FirebaseFirestore.instance.collection('publications').doc(publicationId).delete();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Publication deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting publication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error deleting publication. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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
        'profileImageUrl': _newProfileImageUrl.isNotEmpty ? _newProfileImageUrl : _profileImageUrl,
      });

      setState(() {
        _profileImageUrl = _newProfileImageUrl.isNotEmpty ? _newProfileImageUrl : _profileImageUrl;
        _newProfileImageUrl = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      print('User profile updated successfully!');
    } catch (e) {
      print('Error updating user profile: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error saving profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> selectImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    List<int> imageBytes = await image.readAsBytes();

    String imageUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';

    setState(() {
      _newProfileImageUrl = imageUrl;
    });
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
        title: Center(
          child: Text(
            "FEUP-reUSE",
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontFamily: GoogleFonts.oswald().fontFamily,
            ),
          ),
        ),
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
                      FutureBuilder<ImageProvider?>(
                        future: decodeImage(_newProfileImageUrl.isNotEmpty ? _newProfileImageUrl : _profileImageUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              child: const CircularProgressIndicator(),
                            );
                          } else if (snapshot.data == null) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                            );
                          }
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: snapshot.data!,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: selectImage,
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
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _biographyController,
                  decoration: InputDecoration(
                    labelText: 'Biography',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: saveProfile,
                    child: const Text('Save'),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Logout'),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: loadUserPublications(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
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
                  MaterialPageRoute(builder: (context) => const AddPublicationScreen()),
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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

Future<ImageProvider?> decodeImage(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) {
    return const AssetImage('assets/placeholder_image.png');
  }
  try {
    List<int> imageBytes = base64Decode(imageUrl.split(',').last);
    return MemoryImage(Uint8List.fromList(imageBytes));
  } catch (error) {
    print('Error decoding image: $error');
    return const AssetImage('assets/placeholder_image.png');
  }
}
