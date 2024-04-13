import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';


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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _allUsers.map((user) {
                return ListTile(
                  title: Text(user['name']),
                  onTap: () async {
                    String recipientId = user.id;
                    String recipientName = await _getUserName(recipientId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          recipientId: recipientId,
                          recipientName: recipientName,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
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
                Navigator.pushReplacement(
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
              icon: Icon(Icons.message),
              onPressed: () {},
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

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const ChatScreen({
    required this.recipientId,
    required this.recipientName,
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late Stream<List<ChatMessage>> _messagesStream;
  late Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _messagesStream = _getMessagesStream(widget.recipientId);
    _loadUserNames();
  }

  Stream<List<ChatMessage>> _getMessagesStream(String recipientId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: recipientId)
        .orderBy('timestamp', descending: true) // Sort by timestamp in descending order
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage(
          sender: doc['senderId'],
          receiver: doc['receiverId'],
          content: doc['content'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

    Future<void> _loadUserNames() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final Map<String, String> userNames = {};
      usersSnapshot.docs.forEach((doc) {
        userNames[doc.id] = doc['name'] as String;
      });
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
          });
          _textEditingController.clear();
        } catch (e) {
          print('Error sending message: $e');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipientName}'),
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
                  List<ChatMessage> messages = snapshot.data ?? [];
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final senderId = messages[index].sender;
                      final senderName = _userNames[senderId] ?? 'Unknown';
                      return ListTile(
                        title: Text(messages[index].content),
                        subtitle: Text('$senderName - ${DateFormat.yMd().add_jm().format(messages[index].timestamp)}'),
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
    );
  }
}
