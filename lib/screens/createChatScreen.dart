import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddChatWidget extends StatefulWidget {
  @override
  _AddChatWidgetState createState() => _AddChatWidgetState();
}
class _AddChatWidgetState extends State<AddChatWidget> {
  List _selectedFriends = [];
  late String _chatName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Chat"),
      ),
      body: FutureBuilder(
        future: _getFriends(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List friends = snapshot.data;
            return Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Chat Name'),
                  onChanged: (String value) {
                    setState(() {
                      _chatName = value;
                    });
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CheckboxListTile(
                        value: _selectedFriends.contains(friends[index]['user_id']),
                        onChanged: (bool? value) {
                          if (value == true) {
                            _selectedFriends.add(friends[index]['user_id']);
                          } else {
                            _selectedFriends.remove(friends[index]['user_id']);
                          }
                        },
                        title: Text(friends[index]['user_name'] + " " + friends[index]['user_surname']),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _createChat();
                  },
                  child: Text("Create Chat"),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List> _getFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await http.post(Uri.parse('http://127.0.0.1:5000/get-friends'),
        body: {"token": token});
    return jsonDecode(response.body);
  }

  _createChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token')!;
    var response = await http.post(Uri.parse('http://127.0.0.1:5000/create-chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "friend_ids": _selectedFriends,
          "name": _chatName,
        }));
    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }
}
