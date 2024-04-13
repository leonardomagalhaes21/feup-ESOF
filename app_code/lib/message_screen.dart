import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'profile_screen.dart';

class ChatMessage {
  final String sender;
  final String receiver;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.receiver,
    required this.content,
    required this.timestamp,
  });
}

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<ChatMessage> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  String _selectedRecipientId = '';
  List<DocumentSnapshot> _allUsers = [];
  Stream<List<ChatMessage>>? _messagesStream;

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
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
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

  Stream<List<ChatMessage>> _getMessagesStream(String selectedRecipientId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: selectedRecipientId)
        .orderBy('timestamp', descending: true) // Sort by timestamp in descending order
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatMessage> messages = [];

      for (var doc in snapshot.docs) {
        String senderId = doc['senderId'];
        String receiverId = doc['receiverId'];
        String senderName = await _getUserName(senderId);
        String receiverName = await _getUserName(receiverId);

        messages.add(ChatMessage(
          sender: senderName,
          receiver: receiverName,
          content: doc['content'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
        ));
      }

      return messages;
    });
  }

  void _sendMessage() async {
    String messageText = _textEditingController.text.trim();
    if (messageText.isNotEmpty && _selectedRecipientId.isNotEmpty) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          String senderName = await _getUserName(currentUser.uid);

          // Optimistically update UI before Firestore operation
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                sender: senderName,
                receiver: _selectedRecipientId,
                content: messageText,
                timestamp: DateTime.now(),
              ),
            );
          });

          // Clear text input immediately
          _textEditingController.clear();

          // Send message to Firestore
          await FirebaseFirestore.instance.collection('messages').add({
            'senderId': currentUser.uid,
            'receiverId': _selectedRecipientId,
            'content': messageText,
            'timestamp': Timestamp.now(),
          });
        } catch (e) {
          print('Error sending message: $e');
          // Revert UI changes if Firestore operation fails
          setState(() {
            _messages.removeAt(0);
          });
          // Optionally, display an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message. Please try again.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are not signed in'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a recipient'),
        ),
      );
    }
  }

  Future<void> _selectRecipient(String recipientName) async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: recipientName)
          .limit(1)
          .get();
      if (usersSnapshot.docs.isNotEmpty) {
        String recipientId = usersSnapshot.docs.first.id;
        setState(() {
          _selectedRecipientId = recipientId;
        });
        // Update the messages stream with the new recipient
        _messagesStream = _getMessagesStream(recipientId);
      } else {
        print('User not found with name: $recipientName');
      }
    } catch (e) {
      print('Error selecting recipient: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  _messages = snapshot.data ?? [];
                  return ListView.builder(
                    reverse: true, // Show latest messages at the bottom
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      ChatMessage message = _messages[index];
                      return ListTile(
                        title: Text(message.sender),
                        subtitle: Text(message.content),
                        trailing: Text('${message.timestamp.hour}:${message.timestamp.minute}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Divider(height: 1),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
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
              icon: Icon(Icons.person),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Select Recipient'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: _allUsers.map((user) {
                            return ListTile(
                              title: Text(user['name']),
                              onTap: () {
                                _selectRecipient(user['name']);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MessageScreen(),
    );
  }
}
