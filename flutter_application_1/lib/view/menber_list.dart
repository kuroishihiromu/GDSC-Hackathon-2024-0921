import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'データ表示',
      home: DataListScreen(),
    );
  }
}

class DataListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {
      "id": 2,
      "name": "次郎"
    },
    {
      "id": 1,
      "name": "中野雅",
      "student_id": "2420523"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('データリスト'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: item.containsKey('student_id')
                ? Text('学生ID: ${item['student_id']}')
                : null,
          );
        },
      ),
    );
  }
}
