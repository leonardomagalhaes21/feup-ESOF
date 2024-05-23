import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'profile_screen.dart';
import 'add_publication_screen.dart';
import 'message_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_screen.dart';

class OtherProfiles extends StatefulWidget {
  final String userId;

  const OtherProfiles({Key? key, required this.userId}) : super(key: key);

  @override
  _OtherProfilesState createState() => _OtherProfilesState();
}

class _OtherProfilesState extends State<OtherProfiles> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userProfile;
  double _rating = 0;
  double _lastRating = 0;
  int _totalRatings = 0;
  late Future<QuerySnapshot<Map<String, dynamic>>> _userPublications;
  late Future<QuerySnapshot<Map<String, dynamic>>> _ratings;
  late bool _canRate;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    _userProfile = _getUserProfile();
    _userPublications = _getUserPublications();
    _ratings = _getRatings();

    try {
      final ratingsSnapshot = await _ratings;
      final newRating = _calculateAverageRating(ratingsSnapshot);
      setState(() {
        _rating = newRating;
        _totalRatings = ratingsSnapshot.size;
      });
    } catch (e) {
      print('Error getting data: $e');
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (widget.userId != currentUser.uid) {
          setState(() {
            _canRate = true;
          });
          final userRatingQuery = await FirebaseFirestore.instance
              .collection('ratings')
              .where('ratedUserId', isEqualTo: widget.userId)
              .where('ratingUserId', isEqualTo: currentUser.uid)
              .get();
          if (userRatingQuery.docs.isNotEmpty) {
            final userRating = userRatingQuery.docs.first.data()['rating'];
            setState(() {
              _lastRating = userRating;
            });
          }
        } else {
          setState(() {
            _canRate = false;
          });
        }
      }
    } catch (e) {
      print('Error getting last rating: $e');
    }
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

  Future<QuerySnapshot<Map<String, dynamic>>> _getRatings() async {
    try {
      return await FirebaseFirestore.instance
          .collection('ratings')
          .where('ratedUserId', isEqualTo: widget.userId)
          .get();
    } catch (e) {
      throw Exception('Error fetching ratings: $e');
    }
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

  Future<void> _submitRating(double rating) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userRatingQuery = await FirebaseFirestore.instance
            .collection('ratings')
            .where('ratedUserId', isEqualTo: widget.userId)
            .where('ratingUserId', isEqualTo: currentUser.uid)
            .get();

        if (userRatingQuery.docs.isNotEmpty) {
          final userRatingDoc = userRatingQuery.docs.first;
          await userRatingDoc.reference.update({'rating': rating});
        } else {
          await FirebaseFirestore.instance.collection('ratings').add({
            'rating': rating,
            'ratedUserId': widget.userId,
            'ratingUserId': currentUser.uid,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        print('Rating submitted successfully: $rating');

        await _getData();
      }
    } catch (e) {
      print('Error submitting rating: $e');
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
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (userData['profileImageUrl'] != null)
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: FutureBuilder<ImageProvider?>(
                                  future: decodeImage(userData['profileImageUrl']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.data == null) {
                                      return const CircularProgressIndicator();
                                    }
                                    return CircleAvatar(
                                      radius: 30,
                                      backgroundImage: snapshot.data!,
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    userData['biography'] ?? 'No biography available',
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Average Rating: ${_rating.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$_totalRatings ratings',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_canRate)
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Rate User'),
                                            content: StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                return Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    RatingBar.builder(
                                                      initialRating: _lastRating != 0 ? _lastRating : _rating,
                                                      minRating: 0,
                                                      direction: Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemCount: 5,
                                                      itemSize: 30.0,
                                                      itemBuilder: (context, _) => const Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                      onRatingUpdate: (rating) {
                                                        setState(() {
                                                          _lastRating = rating;
                                                        });
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _submitRating(_lastRating);
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: const Text('Submit Rating'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: const Text('Rate'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 15),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    publication['description'] ?? '',
                                    style: const TextStyle(fontSize: 14),
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
        height: 300,
        fit: BoxFit.contain,
      );
    } catch (e) {
      print('Error decoding image: $e');
      return const Icon(Icons.error);
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
}
