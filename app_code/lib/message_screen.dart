import 'package:flutter/material.dart';
import 'main.dart';
import 'search_screen.dart';
import 'add_publication_screen.dart';
import 'profile_screen.dart';


class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
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
  final List<ChatMessage> _messages = []; // List to store chat messages
  final TextEditingController _textEditingController =
      TextEditingController(); // Controller for the text input field

  String _selectedRecipient = ''; // Variable to store the selected recipient

  // Function to send a message
  void _sendMessage() {
    String messageText = _textEditingController.text.trim();
    if (messageText.isNotEmpty && _selectedRecipient.isNotEmpty) {
      // Create a new ChatMessage object and add it to the list of messages
      ChatMessage newMessage = ChatMessage(
        sender: 'User', // For now, set the sender as 'User'
        content: messageText,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(newMessage);
      });
      // Clear the text input field after sending the message
      _textEditingController.clear();
    } else {
      // Show a snackbar if the recipient is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a recipient'),
        ),
      );
    }
  }

  // Function to handle recipient selection
  void _selectRecipient(String recipient) {
    setState(() {
      _selectedRecipient = recipient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                ChatMessage message = _messages[index];
                return ListTile(
                  title: Text(message.sender),
                  subtitle: Text(message.content),
                  trailing: Text(
                      '${message.timestamp.hour}:${message.timestamp.minute}'),
                );
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
                          children: [
                            ListTile(
                              title: Text('Recipient 1'),
                              onTap: () {
                                _selectRecipient('Recipient 1');
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text('Recipient 2'),
                              onTap: () {
                                _selectRecipient('Recipient 2');
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
