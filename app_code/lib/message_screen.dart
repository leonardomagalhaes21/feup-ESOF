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
import 'package:google_fonts/google_fonts.dart';

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
  const MessageScreen({Key? key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _distinctPublicationIds = [];
  List<String> _filteredPublicationIds = [];

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
          _filteredPublicationIds = _distinctPublicationIds;
        });
      }
    } catch (e) {
      print('Error fetching publication ids: $e');
    }
  }

void _filterConversations(String query) async {
  if (query.isEmpty) {
    _getAllPublicationIds();
  } else {
    final lowerCaseQuery = query.toLowerCase();
    final filteredIds = await Future.wait(_distinctPublicationIds.map((publicationId) async {
      final publicationSnapshot = await FirebaseFirestore.instance
          .collection('publications')
          .doc(publicationId)
          .get();

      if (!publicationSnapshot.exists) return false;

      final publicationData = publicationSnapshot.data();
      if (publicationData == null) return false;
      final title = publicationData['title']?.toLowerCase() ?? '';
      final userId = publicationData['userId'];
      if (userId == null) return false;

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userSnapshot.exists) return false;

      final userData = userSnapshot.data();
      if (userData == null) return false;
      final name = userData['name']?.toLowerCase() ?? '';

      return title.contains(lowerCaseQuery) || name.contains(lowerCaseQuery);
    }));

    setState(() {
      _filteredPublicationIds = [
        for (int i = 0; i < _distinctPublicationIds.length; i++)
          if (filteredIds[i]) _distinctPublicationIds[i]
      ];
    });
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
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search conversations',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _filterConversations,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPublicationIds.length,
              itemBuilder: (context, index) {
                return _buildChatTab(_filteredPublicationIds[index]);
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
          return SizedBox(
            height: 50,
            width: 50,
            
          );
        }
        if (snapshot.hasError) {
          print('Error fetching publication data: ${snapshot.error}');
          return Container();
        }
        final publicationData =
            snapshot.data?.data() as Map<String, dynamic>?;
        if (publicationData == null) {
          return Container();
        }
        final userId = publicationData['userId'] as String;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 50,
                width: 50,
              );
            }
            if (userSnapshot.hasError) {
              print('Error fetching user data: ${userSnapshot.error}');
              return Container();
            }
            final userData =
                userSnapshot.data?.data() as Map<String, dynamic>?;
            if (userData == null) {
              return const Text('User not found');
            }
            final recipientName = userData['name'] as String;
            final publicationImageUrl = publicationData['publicationImageUrl'] as String?;
            final publicationTitle = publicationData['title'] as String;

            final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
            if (currentUserUid == userId) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<List<String>>(
                    future: _getClientIds(publicationId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        print('Error fetching client IDs: ${snapshot.error}');
                        return Container();
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
                                print('Error fetching client name: ${snapshot.error}');
                                return Container();
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
                                      print('Error fetching client data: ${snapshot.error}');
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
    try {
      List<int> imageBytes = base64Decode(imageUrl.split(',').last);
      return MemoryImage(Uint8List.fromList(imageBytes));
    } catch (e) {
      print('Error decoding image: $e');
      return null;
    }
  }
}
