import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'main.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'message_screen.dart';

class OtherProfiles extends StatefulWidget {
  final String userId;

  const OtherProfiles({Key? key, required this.userId}) : super(key: key);

  @override
  _OtherProfilesState createState() => _OtherProfilesState();
}

class _OtherProfilesState extends State<OtherProfiles> {
  late Future<DocumentSnapshot> _userProfile;
  double _rating = 0; // Valor inicial do rating

  @override
  void initState() {
    super.initState();
    _userProfile = _getUserProfile();
  }

  Future<DocumentSnapshot> _getUserProfile() async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
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
              child: Padding(
                padding: const EdgeInsets.only(
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
      body: FutureBuilder<DocumentSnapshot>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          } else {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
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
                          SizedBox(height: 10),
                          // Display de estrelas
                          RatingBar.builder(
                            initialRating: _rating,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 30.0,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: _rateUser,
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    userData['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10),
                  Text(
                    userData['biography'] ?? 'No biography available',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Lógica para submeter a avaliação
                      print('Avaliação submetida: $_rating');
                    },
                    child: Text('Avaliar'),
                  ),
                ],
              ),
            );
          }
        },
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
              onPressed: () {},
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
