import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('一覧'),
            bottom: const TabBar(tabs: <Widget>[
              Tab(child: Text("TeamA")),
              Tab(child: Text("TeamB")),
              Tab(child: Text("TeamC")),
            ]),
          ),
          body: const TabBarView(
            children: <Widget>[
              StudentCardList(), // 一枚目のタブにStudentCardListを表示
              Center(child: Text("Team B の情報がここに表示されます。")),
              Center(child: Text("Team C の情報がここに表示されます。")),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentCardList extends StatelessWidget {
  const StudentCardList({super.key});

  Future<List<Map<String, String>>> loadStudents() async {
    final String response = await rootBundle.loadString('assets/Database.json');
    final data = json.decode(response);
    
    // dynamicを使って正しい型に変換
    return List<Map<String, String>>.from(
      (data['students'] as List).map((student) => Map<String, String>.from(student))
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: loadStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final students = snapshot.data!;
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
      },
    );
  }
}