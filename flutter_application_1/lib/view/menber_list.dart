import 'dart:convert';  // JSONをデコードするために必要
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // assetsから読み込むために必要

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Card Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TeamA'),
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
      "facaulty": "****",
      "department": "*****",
       "created_at": "2024/09/21"
    },
    {
      "id": "2",
      "name": "佐藤有紗",
      "student_id": "********",
      "university": "東京都立大学",
      "facaulty": "****",
      "department": "*****",
       "created_at": "2024/09/21"
    }
  ];

  StudentCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  students[index]['name']!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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