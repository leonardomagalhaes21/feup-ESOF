import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'profile_screen.dart';
import 'message_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String? publicationId;

  const ChatScreen({
    required this.recipientId,
    required this.recipientName,
    this.publicationId,
    super.key,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late Stream<List<ChatMessage>> _messagesStream;
  late Map<String, String> _userNames = {};
  String? _publicationTitle;

  @override
  void initState() {
    super.initState();
    String senderId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _messagesStream = _getMessagesStream(senderId, widget.recipientId, widget.publicationId);
    _loadUserNames();
    _fetchPublicationTitle();
  }

  Future<void> _fetchPublicationTitle() async {
    if (widget.publicationId != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('publications').doc(widget.publicationId).get();
        if (doc.exists) {
          setState(() {
            _publicationTitle = doc['title'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching publication title: $e');
      }
    }
  }

  Stream<List<ChatMessage>> _getMessagesStream(String senderId, String recipientId, String? publicationId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      List<ChatMessage> messages = [];
      for (var doc in snapshot.docs) {
        if (((doc['senderId'] == senderId && doc['receiverId'] == recipientId) ||
            (doc['senderId'] == recipientId && doc['receiverId'] == senderId)) &&
            doc['publicationId'] == publicationId) {
          messages.add(
            ChatMessage(
              sender: doc['senderId'],
              receiver: doc['receiverId'],
              content: doc['content'],
              timestamp: (doc['timestamp'] as Timestamp).toDate(),
              publicationId: doc['publicationId'],
            ),
          );
        }
      }
      return messages;
    });
  }

  Future<void> _loadUserNames() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final Map<String, String> userNames = {};
      for (var doc in usersSnapshot.docs) {
        userNames[doc.id] = doc['name'] as String;
      }
      setState(() {
        _userNames = userNames;
      });
    } catch (e) {
      print('Error loading user names: $e');
    }
  }

  void _sendMessage() {
    String messageText = _textEditingController.text.trim();
    if (messageText.isNotEmpty) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          FirebaseFirestore.instance.collection('messages').add({
            'senderId': currentUser.uid,
            'receiverId': widget.recipientId,
            'content': messageText,
            'timestamp': Timestamp.now(),
            'publicationId': widget.publicationId,
          });
          _textEditingController.clear();
        } catch (e) {
          print('Error sending message: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send message. Please try again.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not signed in'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _publicationTitle != null
            ? Text('$_publicationTitle - Chat with ${widget.recipientName}')
            : Text('Chat with ${widget.recipientName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _publicationTitle == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<ChatMessage> messages = snapshot.data ?? [];
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message.sender == FirebaseAuth.instance.currentUser?.uid;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _userNames[message.sender] ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    timeago.format(message.timestamp),
                                    style: const TextStyle(fontSize: 10.0),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isCurrentUser ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                message.content,
                                style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(240, 240, 240, 1),
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
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
                  MaterialPageRoute(builder: (context) => const AddPublicationScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                Navigator.pushReplacement(
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
}
