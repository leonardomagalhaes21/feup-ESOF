import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class ChatMessage {
  final String sender;
  final String receiver;
  final String content;
  final DateTime timestamp;
  final String publicationId;

  ChatMessage({
    required this.sender,
    required this.receiver,
    required this.content,
    required this.timestamp,
    required this.publicationId,
  });
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  List<String> _distinctPublicationIds = [];

  @override
  void initState() {
    super.initState();
    _getAllPublicationIds();
  }

  Future<void> _getAllPublicationIds() async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid != null) {
        final QuerySnapshot senderMessagesSnapshot = await FirebaseFirestore.instance
            .collection('messages')
            .where('senderId', isEqualTo: currentUserUid)
            .get();

        final QuerySnapshot receiverMessagesSnapshot = await FirebaseFirestore.instance
            .collection('messages')
            .where('receiverId', isEqualTo: currentUserUid)
            .get();

        final List<String> distinctPublicationIds = [];

        for (var doc in senderMessagesSnapshot.docs) {
          final publicationId = doc['publicationId'] as String;
          if (!distinctPublicationIds.contains(publicationId)) {
            distinctPublicationIds.add(publicationId);
          }
        }
        
        for (var doc in receiverMessagesSnapshot.docs) {
          final publicationId = doc['publicationId'] as String;
          if (!distinctPublicationIds.contains(publicationId)) {
            distinctPublicationIds.add(publicationId);
          }
        }

        setState(() {
          _distinctPublicationIds = distinctPublicationIds;
        });
      }
    } catch (e) {
      print('Error fetching publication ids: $e');
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
      body: Column(
        children: [
          Expanded(
            child: _distinctPublicationIds.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _distinctPublicationIds.length,
                    itemBuilder: (context, index) {
                      final publicationId = _distinctPublicationIds[index];

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('publications').doc(publicationId).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          final publicationData = snapshot.data?.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic> or null
                          if (publicationData == null) {
                            return const Text('Publication not found');
                          }
                          final userId = publicationData['userId'] as String;
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (userSnapshot.hasError) {
                                return Text('Error: ${userSnapshot.error}');
                              }
                              final userData = userSnapshot.data?.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic> or null
                              if (userData == null) {
                                return const Text('User not found');
                              }
                              final recipientName = userData['name'] as String;
                              final recipientImageUrl = userData['profileImageUrl'] as String?;
                              final publicationTitle = publicationData['title'] as String;
                              
                              return Column(
                                children: [
                                  FutureBuilder<List<String>>(
                                    future: _getBuyerNames(publicationId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      final buyerNames = snapshot.data ?? [];
                                      return Column(
                                        children: buyerNames.map((buyerName) {
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                              child: Text(
                                                '$publicationTitle - $buyerName',
                                                style: const TextStyle(fontSize: 18.0),
                                              ),
                                            ),
                                            leading: CircleAvatar(
                                              radius: 30,
                                              backgroundImage: NetworkImage(recipientImageUrl ?? ''), // If no image URL provided, use empty string
                                            ),
                                            onTap: () async {

                                              try {
                                                final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
                                                if (currentUserUid != null) {
                                                  final senderId = currentUserUid;
                                                  final buyerId = await _getBuyerId(publicationId, senderId);
                                                  final recipientId = buyerId;
                                                  final recipientName = buyerName;
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ChatScreen(
                                                        publicationId: publicationId,
                                                        recipientId: recipientId,
                                                        recipientName: recipientName,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('You are not signed in'),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                print('Error: $e');
                                                Navigator.pop(context); // Close loading dialog
                                              }
                                            },
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddPublicationScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {},
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

  Future<String> _getUserName(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userSnapshot.get('name');
    } catch (e) {
      print('Error fetching user name: $e');
      return '';
    }
  }

  Future<List<String>> _getBuyerNames(String publicationId) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    try {
      final senderMessagesSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('publicationId', isEqualTo: publicationId)
          .get();

      final buyerNames = <String>{};

      for (var doc in senderMessagesSnapshot.docs) {
        final buyerId = doc['receiverId'] as String;
        final buyerName = await _getUserName(buyerId);
        if (buyerId != currentUserUid){
          buyerNames.add(buyerName);
        }
      }

      return buyerNames.toList();
    } catch (e) {
      print('Error fetching buyer names: $e');
      return [];
    }
  }

  Future<String> _getBuyerId(String publicationId, String senderId) async {
    try {
      final senderMessagesSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('publicationId', isEqualTo: publicationId)
          .where('senderId', isEqualTo: senderId)
          .get();

      if (senderMessagesSnapshot.docs.isNotEmpty) {
        return senderMessagesSnapshot.docs.first['receiverId'] as String;
      } 
      else {
        return ''; // If no buyer found, return an empty string
      }
    } catch (e) {
      print('Error fetching buyer ID: $e');
      return ''; // Handle errors by returning an empty string
    }
  }
}
