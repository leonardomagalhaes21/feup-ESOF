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
  const MessageScreen({Key? key}) : super(key: key);

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
                              
                              return ListTile(
                                title: Text(publicationTitle),
                                subtitle: Text(recipientName),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(recipientImageUrl ?? ''), // If no image URL provided, use empty string
                                ),
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false, // Prevent dialog from being dismissed by tapping outside
                                    builder: (BuildContext context) {
                                      return Center(
                                        child: CircularProgressIndicator(), // Show loading indicator
                                      );
                                    },
                                  );

                                  try {
                                    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
                                    if (currentUserUid != null) {
                                      final publicationId = _distinctPublicationIds[index];
                                      final senderId = currentUserUid;
                                      String? buyerId;
                                      final senderMessagesSnapshot = await FirebaseFirestore.instance
                                        .collection('messages')
                                        .where('publicationId', isEqualTo: publicationId)
                                        .where('senderId', isEqualTo: senderId)
                                        .get();
                                      final receiverMessagesSnapshot = await FirebaseFirestore.instance
                                        .collection('messages')
                                        .where('publicationId', isEqualTo: publicationId)
                                        .where('receiverId', isEqualTo: senderId)
                                        .get();

                                      if (senderMessagesSnapshot.docs.isNotEmpty) {
                                        buyerId = senderMessagesSnapshot.docs.first['receiverId'] as String;
                                      } else if (receiverMessagesSnapshot.docs.isNotEmpty) {
                                        buyerId = receiverMessagesSnapshot.docs.first['senderId'] as String;
                                      } else {
                                        print('No messages found for this publication');
                                        return;
                                      }

                                      final recipientId = buyerId;
                                      final recipientName = await _getUserName(recipientId);
                                      Navigator.pop(context); // Close loading dialog
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
}
