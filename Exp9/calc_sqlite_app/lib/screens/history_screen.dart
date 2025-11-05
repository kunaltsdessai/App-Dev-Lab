import 'package:flutter/material.dart';
import 'package:calc_sqlite_app/db/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  void loadHistory() async {
    final data = await DatabaseHelper.instance.getHistory();
    setState(() => history = data);
  }

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Calculation History"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await DatabaseHelper.instance.clearHistory();
              loadHistory();
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                "No history yet",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  title: Text(
                    item['expression'],
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "= ${item['result']}",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
    );
  }
}
