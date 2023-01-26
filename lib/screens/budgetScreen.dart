
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BudgetScreen extends StatelessWidget {
  Future<void> _addIncomeOutcome(bool isIncome, double amount,
      DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token')!;
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/add-income-outcome'),
      body: {
        'token': token,
        'income_outcome': isIncome,
        'amount': amount,
        'date': date.toIso8601String(),
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add income/outcome');
    }
  }

  Future<List<Map<String, dynamic>>> _getIncomeOutcomeHistory(
      DateTime startDate, int countDays) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token')!;
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/show-income-outcome-history'),
      body: {
        'token': token,
        'start_date': startDate.toIso8601String(),
        'count_days': countDays,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get income/outcome history');
    }
    return jsonDecode(response.body);
  }

  late double _amount;
  late DateTime _date;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Add budget change',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _amount = double.parse(value);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
              onChanged: (value) {
                _date = DateTime.parse(value);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  child: Text('Add Income'),
                  onPressed: () {
                    _addIncomeOutcome(true, _amount, _date);
                  },
                ),
                ElevatedButton(
                  child: Text('Add Outcome'),
                  onPressed: () {
                    _addIncomeOutcome(false, _amount, _date);
                  },
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  child: Text('Show History'),
                  onPressed: () async {
                    DateTime startDate = DateTime.now();
                    int countDays = 7;
                    List<Map<String, dynamic>> history = await _getIncomeOutcomeHistory(startDate, countDays);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryPage(history: history),
                      ),
                    );
                  }
              )
          )
        ],
      ),
    );
  }

}

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  HistoryPage({required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income/Outcome History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(history[index]['amount'].toString()),
            subtitle: Text(history[index]['date'].toString()),
          );
        },
      ),
    );
  }
}