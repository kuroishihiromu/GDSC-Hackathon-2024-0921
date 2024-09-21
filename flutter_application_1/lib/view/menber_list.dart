import 'dart:convert';  // JSONをデコードするために必要
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // assetsから読み込むために必要

class Member {
  final int memberId;
  final String name;
  final String studentId; 
  final String universityname;
  final String faculty;
  final String department;
  final String createdat;

  Member({required this.memberId, required this.name, required this.studentId, required this. universityname, required this. faculty, required this. createdat, required this.department}) 
  

  // JSONデータをDartオブジェクトに変換するためのファクトリメソッド
  // ignore: empty_constructor_bodies
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['id'],
      name: json['name'],
      studentId: json['student_id'],
      universityname: json['university_name'],
      faculty: json['faculty'],
      department: json['department'],
      createdat: json['created_at']
    );
  }
}

class MemberListService {
  // assetsからdatabase.jsonを読み込んで、Memberのリストを返す
  Future<List<Member>> loadMemberList() async {
    // assetsからJSONファイルを読み込み
    final String response = await rootBundle.loadString('assets/database.json');
    final data = json.decode(response); // JSONデータをデコード
    List<dynamic> membersJson = data['member_list'];
    
    // 各メンバーのデータをMemberオブジェクトに変換してリストにする
    return membersJson.map((json) => Member.fromJson(json)).toList();
  }
}

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