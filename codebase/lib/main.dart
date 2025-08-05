import 'package:flutter/material.dart';

void main() {
  runApp(ConversaAIApp());
}

class ConversaAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF7B61FF), // Accent purple color
        scaffoldBackgroundColor: Color(0xFFF5F5F5), // Soft off-white background
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Color(0xFF333333), fontSize: 16), // Updated text style
          headline6: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      home: ConversaAIHome(),
    );
  }
}

class ConversaAIHome extends StatefulWidget {
  @override
  _ConversaAIHomeState createState() => _ConversaAIHomeState();
}

class _ConversaAIHomeState extends State<ConversaAIHome> {
  TextEditingController _controller = TextEditingController();
  List<String> _messages = [];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(_controller.text);
        _controller.clear(); // Clear the input field after sending
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ConversaAI", style: TextStyle(fontSize: 24)),
        backgroundColor: Color(0xFF7B61FF), // Accent purple
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Bubble(message: _messages[index]),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF7B61FF)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  final String message;

  Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFE1E1FF), // Light purple background for messages
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(color: Color(0xFF333333), fontSize: 16),
        ),
      ),
    );
  }
}
