import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendsScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _friendId;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _addFriend(String friendId) async {
    String? token = await _getToken();
    final response = await http.post(Uri.parse('http://127.0.0.1:5000/add-friend'),
        body: {'token': token, 'friend_id': friendId});
  }

  Future<void> _removeFriend(String friendId) async {
    String? token = await _getToken();
    final response = await http.post(Uri.parse('http://127.0.0.1:5000/remove-friend'),
        body: {'token': token, 'friend_id': friendId});
  }

  Future<List<dynamic>> _getFriends() async {
    String? token = await _getToken();
    final response = await http
        .post(Uri.parse('http://127.0.0.1:5000/get-friends'), body: {'token': token});
    return List<dynamic>.from(json.decode(response.body));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Friends'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder(
                future: _getFriends(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                                '${snapshot.data[index]['user_name']} ${snapshot.data[index]['user_surname']}'),
                            trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _removeFriend(
                                      snapshot.data[index]['user_id']);
                                }),
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Friend ID'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a friend ID';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _friendId = value!;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _addFriend(_friendId);
                        }
                      },
                      child: Text('Add Friend'),
                    )
                  ],
                ))
          ],
        ));
  }
}
