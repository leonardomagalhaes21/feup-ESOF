import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'dart:convert';
import 'dart:typed_data';

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
        final QuerySnapshot senderMessagesSnapshot = await FirebaseFirestore
            .instance
            .collection('messages')
            .where('senderId', isEqualTo: currentUserUid)
            .get();

        final QuerySnapshot receiverMessagesSnapshot = await FirebaseFirestore
            .instance
            .collection('messages')
            .where('receiverId', isEqualTo: currentUserUid)
            .get();

        // Use a Set to store unique publication IDs
        final Set<String> distinctPublicationIds = {};

        for (var doc in senderMessagesSnapshot.docs) {
          final publicationId = doc['publicationId'] as String;
          distinctPublicationIds.add(publicationId);
        }

        for (var doc in receiverMessagesSnapshot.docs) {
          final publicationId = doc['publicationId'] as String;
          distinctPublicationIds.add(publicationId);
        }

        setState(() {
          _distinctPublicationIds = distinctPublicationIds.toList();
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
      body: ListView.builder(
        itemCount: _distinctPublicationIds.length,
        itemBuilder: (context, index) {
          return _buildChatTab(_distinctPublicationIds[index]);
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

  Future<List<String>> _getClientIds(String publicationId) async {
  try {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('publicationId', isEqualTo: publicationId)
        .get();

    final Set<String> distinctClientIds = {};

    for (var doc in messagesSnapshot.docs) {
      final senderId = doc['senderId'] as String;
      final receiverId = doc['receiverId'] as String;
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid != null) {
        if (senderId == currentUserUid) {
          distinctClientIds.add(receiverId);
        } else if (receiverId == currentUserUid) {
          distinctClientIds.add(senderId);
        }
      }
    }

    return distinctClientIds.toList();
  } catch (e) {
    print('Error fetching client IDs: $e');
    return [];
  }
}

void _navigateToChatScreen(BuildContext context, String publicationId, String recipientId) {
  _getUserName(recipientId).then((recipientName) {
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
  }).catchError((error) {
    print('Error: $error');
  });
}



Widget _buildChatTab(String publicationId) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('publications')
        .doc(publicationId)
        .get(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      final publicationData =
          snapshot.data?.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic> or null
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
          final userData =
              userSnapshot.data?.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic> or null
          if (userData == null) {
            return const Text('User not found');
          }
          final recipientName = userData['name'] as String;
          final publicationImageUrl = publicationData['publicationImageUrl'] as String?;
          final publicationTitle = publicationData['title'] as String;
          final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

          // Check if the current user is the seller of the publication
          final bool isCurrentUserSeller = currentUserUid == userId;

          // If current user is the seller, display additional rows with client names
          if (isCurrentUserSeller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display additional rows with client names
                FutureBuilder<List<String>>(
                  future: _getClientIds(publicationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final clientIds = snapshot.data ?? [];
                    return Column(
                      children: clientIds.map((clientId) {
                        return FutureBuilder<String>(
                          future: _getUserName(clientId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            final clientName = snapshot.data ?? 'Unknown';
                            return ListTile(
                              contentPadding: const EdgeInsets.all(8.0),
                              title: Text(
                                '$publicationTitle - $clientName',
                                style: const TextStyle(fontSize: 18.0),
                              ),
                              leading: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(clientId).get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return const Icon(Icons.error); 
                                  }
                                  final clientData = snapshot.data?.data() as Map<String, dynamic>?;
                                  if (clientData == null || !clientData.containsKey('profileImageUrl')) {
                                    return const Icon(Icons.error);
                                  }
                                  return FutureBuilder<ImageProvider?>(
                                    future: decodeImage(publicationImageUrl ?? ''),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
                                        return const CircularProgressIndicator();
                                      }
                                      return CircleAvatar(
                                        radius: 30,
                                        backgroundImage: snapshot.data!,
                                      );
                                    },
                                  );
                                },
                              ),
                              onTap: () {
                                _navigateToChatScreen(context, publicationId, clientId);
                              },
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          } else {
            // If current user is not the seller, display only the seller's name
            return ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              title: Text(
                '$publicationTitle - $recipientName',
                style: const TextStyle(fontSize: 18.0),
              ),
              leading: FutureBuilder<ImageProvider?>(
                future: decodeImage(publicationImageUrl ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
                    return const CircularProgressIndicator();
                  }
                  return CircleAvatar(
                    radius: 30,
                    backgroundImage: snapshot.data!,
                  );
                },
              ),
              onTap: () async {
                try {
                  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
                  if (currentUserUid != null) {
                    final sellerId = publicationData['userId'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          publicationId: publicationId,
                          recipientId: sellerId,
                          recipientName: recipientName,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('You are not signed in'),
                    ));
                  }
                } catch (e) {
                  print('Error: $e');
                }
              },
            );
          }
        },
      );
    },
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

  Future<ImageProvider?> decodeImage(String imageUrl) async {
    List<int> imageBytes = base64Decode(imageUrl.split(',').last);
    return MemoryImage(Uint8List.fromList(imageBytes));
  }
}

