import 'package:flutter/material.dart';
import 'main.dart';
import 'add_publication_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';
import 'other_profiles_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _allUsers = [];
  List<QueryDocumentSnapshot> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _getAllUsers();
  }

  Future<void> _getAllUsers() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _allUsers = usersSnapshot.docs;
        _filteredUsers = _allUsers;
      });
    } catch (e) {
      print('Error fetching users: $e');
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _filterUsers(value.trim());
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      'No users found for your search.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> userData =
                          _filteredUsers[index].data()
                              as Map<String, dynamic>;
                      return ListTile(
                        leading: FutureBuilder<ImageProvider?>(
                          future: decodeImage(userData['profileImageUrl']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                snapshot.data == null) {
                              return const CircleAvatar(
                                child: Icon(Icons.person),
                              );
                            }
                            if (snapshot.hasError) {
                              print('Error decoding image: ${snapshot.error}');
                              return const CircleAvatar(
                                child: Icon(Icons.person),
                              );
                            }
                            return CircleAvatar(
                              backgroundImage: snapshot.data,
                            );
                          },
                        ),
                        title: Text(userData['name']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtherProfiles(
                                userId: _filteredUsers[index].id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
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

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers
            .where((user) => (user.data() as Map<String, dynamic>)['name']
                .toString()
                .toLowerCase()
                .startsWith(query.toLowerCase()))
            .toList();
      }
    });
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
}
