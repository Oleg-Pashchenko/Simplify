import 'package:app/screens/createChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'chatScreen.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getChats(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List chats = snapshot.data;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {

                return ElevatedButton(
                  child: Text(chats[index][1]),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chats[index][0],
                            chatName: chats[index][1]
                          )),
                    );
                  },
                );
              },
            );

          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddChatWidget()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List> _getChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await http.post(Uri.parse('http://127.0.0.1:5000/get-chats'),
        body: {"token": token});
    return jsonDecode(response.body);
  }
}
