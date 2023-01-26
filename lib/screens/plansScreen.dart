import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlansPage extends StatefulWidget {
  @override
  _PlansPageState createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<dynamic> _plans = [];

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token')!;
  }

  Future<void> _addPlan() async {
    String token = await _getToken();
    String name = _nameController.text;
    String target = _targetController.text;
    String description = _descriptionController.text;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/add-plan'),
      body: {
        'token': token,
        'name': name,
        'target': target,
        'description': description
      },
    );
    if (response.statusCode == 200) {
      print("Plan added successfully");
      _getPlans();
    } else {
      print("Error adding plan");
    }
  }

  Future<void> _deletePlan(String planId) async {
    String token = await _getToken();

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/delete-plan'),
      body: {
        'token': token,
        'plan_id': planId,
      },
    );
    if (response.statusCode == 200) {
      print("Plan deleted successfully");
      _getPlans();
    } else {
      print("Error deleting plan");
    }
  }

  Future<void> _getPlans() async {
    String token = await _getToken();
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/show-plans'),
      body: {
        'token': token,
      },
    );
    final responseBody = jsonDecode(response.body);
    print(responseBody);
    setState(() {
      _plans = responseBody;
    });
  }

  @override
  void initState() {
    super.initState();
    _getPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _targetController,
              decoration: InputDecoration(labelText: 'Target'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            ElevatedButton(
              onPressed: _addPlan,
              child: Text('Add Plan'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _plans.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_plans[index][1]),
                    subtitle: Text(_plans[index][2]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deletePlan(_plans[index][0].toString());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
