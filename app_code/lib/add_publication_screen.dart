import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'main.dart';
import 'search_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';

class AddPublicationScreen extends StatefulWidget {
  const AddPublicationScreen({Key? key});

  @override
  _AddPublicationScreenState createState() => _AddPublicationScreenState();
}

class _AddPublicationScreenState extends State<AddPublicationScreen> {
  late String _publicationImageUrl;
  final _auth = FirebaseAuth.instance;
  late User? _currentUser;
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController _descriptionController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _publicationImageUrl = '';
    _descriptionController = TextEditingController();
    _titleController = TextEditingController();
  }

  Future<void> uploadImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image == null) return;

    List<int> imageBytes = await image.readAsBytes();

    setState(() {
      _publicationImageUrl = base64Encode(imageBytes);
    });
  }

  Future<void> uploadPublication() async {
    try {
      if (_publicationImageUrl.isNotEmpty) {
        DocumentReference publicationRef =
            await FirebaseFirestore.instance.collection('publications').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'publicationImageUrl': _publicationImageUrl,
          'userId': _currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('Publication uploaded successfully!');
      } else {
        print('Please select an image first.');
      }
    } catch (e) {
      print('Error uploading publication: $e');
    }
    setState(() {
      _publicationImageUrl = '';
      _descriptionController.clear();
      _titleController.clear();
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text('Choose from Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              uploadImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take a Picture'),
                            onTap: () {
                              Navigator.pop(context);
                              uploadImage(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            _publicationImageUrl.isNotEmpty
                ? SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.memory(
                      base64.decode(_publicationImageUrl.split(',').last),
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter a title...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Write a description...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadPublication,
              child: const Text('Upload Publication'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddPublicationScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessageScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
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

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
