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

  Member({required this.memberId, required this.name, required this.studentId, required this. universityname, required this. faculty, required this. createdat, required this.department});
  

  // JSONデータをDartオブジェクトに変換するためのファクトリメソッド
  // ignore: empty_constructor_bodies
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['member_id'],
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
    final String response = await rootBundle.loadString('assets/Database.json');
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
          body: TabBarView(
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
  final students = MemberListService() as List<Map<String, String>>;

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