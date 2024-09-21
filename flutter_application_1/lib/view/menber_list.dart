import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Card Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('TeamA'),
        ),
        body: StudentCardList(),
      ),
    );
  }
}

class StudentCardList extends StatelessWidget {
  final List<Map<String, String>> students = [
    {
      "id": "1",
      "name": "中野雅",
      "student_id": "*******",
      "university": "お茶の水女子大学",
      "facaulty": "****"
    },
    {
      "id": "2",
      "name": "佐藤有紗",
      "student_id": "********",
      "university": "東京都立大学",
      "facaulty": "****"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  students[index]['name']!,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("学籍番号: ${students[index]['student_id']}"),
                Text("大学: ${students[index]['university']}"),
                Text("学部: ${students[index]['facaulty']}"),
              ],
            ),
          ),
        );
      },
    );
  }
}