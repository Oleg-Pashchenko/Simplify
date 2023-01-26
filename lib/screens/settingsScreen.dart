import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _surnameController = TextEditingController();
  late String _token;

  void _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token')!;

    var response = await http.post(
      Uri.parse('http://127.0.0.1:5000/get-user-info'),
      body: {'token': _token},
    );

    if (response.statusCode == 200) {
      var responseJson = json.decode(response.body);
      _idController.text = responseJson['id'];
      _nameController.text = responseJson['name'];
      _surnameController.text = responseJson['surname'];
    }
  }

  void _changeUserInfo(BuildContext context) async {
    var response = await http.post(
      Uri.parse('http://127.0.0.1:5000/change-user-info'),
      body: {
        'token': _token,
        'name': _nameController.text,
        'surname': _surnameController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _getUserInfo();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Edit your information',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
                decoration: InputDecoration(labelText: 'Id'),
                controller: _idController
            ),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(labelText: 'Surname'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => {
                _changeUserInfo(context),
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Success'),
                      content: Text('Successfully changed user info'),
                      actions: <Widget>[
                        ElevatedButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                )
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
