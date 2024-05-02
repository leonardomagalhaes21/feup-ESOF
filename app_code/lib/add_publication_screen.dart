import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'main.dart';
import 'search_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                child: ElevatedButton.icon(
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
                  icon: const Icon(Icons.image),
                  label: const Text('Insert Image Publication'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _publicationImageUrl.isNotEmpty
                ? SizedBox(
                    height: 200,
                    child: Image.memory(
                      base64.decode(_publicationImageUrl.split(',').last),
                    ),
                  )
                : Container(),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter a title...',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Write a description...',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: uploadPublication,
                  child: const Text('Upload Publication'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
