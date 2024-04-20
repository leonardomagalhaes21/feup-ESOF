import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'main.dart';
import 'profile_screen.dart';
import 'add_publication_screen.dart';
import 'message_screen.dart';

class OtherProfiles extends StatefulWidget {
  final String userId;

  const OtherProfiles({super.key, required this.userId});

  @override
  _OtherProfilesState createState() => _OtherProfilesState();
}

class _OtherProfilesState extends State<OtherProfiles> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userProfile;
  double _rating = 0; // Initial rating value
  late Future<QuerySnapshot<Map<String, dynamic>>> _userPublications;

  @override
  void initState() {
    super.initState();
    _userProfile = _getUserProfile();
    _userPublications = _getUserPublications();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserProfile() async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getUserPublications() async {
    try {
      return await FirebaseFirestore.instance
          .collection('publications')
          .where('userId', isEqualTo: widget.userId)
          .get();
    } catch (e) {
      throw Exception('Error fetching user publications: $e');
    }
  }

  void _rateUser(double rating) {
    setState(() {
      _rating = rating;
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
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userProfile,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (profileSnapshot.hasError) {
            return Center(child: Text('Error: ${profileSnapshot.error}'));
          } else if (!profileSnapshot.hasData || profileSnapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            var userData = profileSnapshot.data!.data()!;
            return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: _userPublications,
              builder: (context, publicationsSnapshot) {
                if (publicationsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (publicationsSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${publicationsSnapshot.error}'));
                } else {
                  var userPublications = publicationsSnapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userData['profileImageUrl'] != null)
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(userData['profileImageUrl']),
                                ),
                                const SizedBox(height: 10),
                                // Display star rating
                                RatingBar.builder(
                                  initialRating: _rating,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 30.0,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: _rateUser,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        Text(
                          userData['name'],
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userData['biography'] ?? 'No biography available',
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Logic to submit rating
                            print('Rating submitted: $_rating');
                          },
                          child: const Text('Rate'),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Publications:',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: userPublications.size,
                            itemBuilder: (context, index) {
                              var publication =
                                  userPublications.docs[index].data();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (publication['publicationImageUrl'] !=
                                      null) ...[
                                    FutureBuilder<Widget>(
                                      future: _decodeBase64Image(
                                          publication['publicationImageUrl']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                              child: Icon(Icons.error));
                                        } else {
                                          return snapshot.data!;
                                        }
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Text(
                                    publication['title'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    publication['description'] ?? '',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
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
                  MaterialPageRoute(
                      builder: (context) => const MessageScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Widget> _decodeBase64Image(String imageUrl) async {
    try {
      List<int> imageBytes = base64Decode(imageUrl.split(',').last);
      Uint8List imageData = Uint8List.fromList(imageBytes);
      return Image.memory(
        imageData,
        width: double.infinity,
        height: 400,
        fit: BoxFit.contain,
      );
    } catch (e) {
      print('Error decoding image: $e');
      return const Icon(Icons.error);
    }
  }
}
