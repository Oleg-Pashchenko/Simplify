import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String chatName;

  ChatScreen({required this.chatId, required this.chatName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$chatName"),
      ),
      body: ChatBody(chatId: int.parse(chatId)),
    );
  }
}

class ChatBody extends StatefulWidget {
  final int chatId;

  ChatBody({required this.chatId});

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  late String _token = "";
  late List<Map<String, dynamic>> _messages = [];
  late TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getToken();
    // Refresh messages every second
    _fetchMessages();
  }

  void _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token')!;
    });
  }

  void _fetchMessages() async {
    if (true) {
      final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/chat-get-updates'),
          body: {'token': _token, 'chat_id': widget.chatId.toString()});
      if (response.statusCode == 200) {
        List messages = json.decode(response.body);
        List<Map<String, dynamic>> formattedMessages = messages
            .map((message) => {
          'message': message[0],
          'sender_name': message[1],
          'message_time': message[2],
          'is_my': message[3] // bool
        })
            .toList();
        if (mounted) {
          setState(() {
            _messages = formattedMessages;
            Timer(Duration(seconds: 1), () => _fetchMessages());
          });
        }
      }
    }
  }

  void _sendMessage(String message) async {
    final response = await http
        .post(Uri.parse('http://127.0.0.1:5000/chat-new-message'), body: {
      'token': _token,
      'chat_id': widget.chatId.toString(),
      'message': message
    });
    if (response.statusCode == 200) {
      _fetchMessages();
    }
  }

  final _textController = TextEditingController();
  void _clearTextField() {
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
    Expanded(
    child: ListView.builder(
      itemCount: _messages.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> message = _messages[index];
        return ListTile(
          title: Align(
            alignment: message['is_my'] ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: message['is_my'] ? Colors.lightBlue : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                message['message'],
                style: TextStyle(
                    color: message['is_my'] ? Colors.white : Colors.black
                ),
              ),
            ),
          ),
          subtitle: Align(
            alignment: message['is_my'] ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
                message['sender_name'] + ' ' + message['message_time']
            ),
          ),
        );
      },
    ),
    ),
    Container(
    padding: EdgeInsets.all(8.0),
    child: Row(
    children: <Widget>[
    Expanded(
    child: TextField(
      onSubmitted: (text) {
        _sendMessage(text);
        _textController.clear();
      },
      controller: _textController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Send a message',
      ),
    ),
    ),
      ElevatedButton(
        onPressed: () {
          _sendMessage(_textController.text);
          _clearTextField();
        },
        child: Text("Send"),
      )
    ],
    ),
    ),
      ],
    );
  }
}

