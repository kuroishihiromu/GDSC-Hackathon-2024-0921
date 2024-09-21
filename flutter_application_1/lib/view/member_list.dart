import 'dart:convert';  // JSONをデコードするために必要
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // assetsから読み込むために必要



class Member {
  final int memberId;
  final String? name;
  final String? studentId; 
  final String? universityname;
  final String? faculty;
  final String? department;
  final String? createdat;

  Member({required this.memberId, required this.name, required this.studentId, required this. universityname, required this. faculty, required this. createdat, required this.department});
  

  // JSONデータをDartオブジェクトに変換するためのファクトリメソッド
  // ignore: empty_constructor_bodies
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['member_id'] ?? 0,
      name: json['name'] ?? "NULL",
      studentId: json['student_id'] ?? "NULL",
      universityname: json['university_name'] ?? "NULL",
      faculty: json['faculty'] ?? "NULL",
      department: json['department'] ?? "NULL",
      createdat: json['created_at'] ?? "NULL"
    );
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
        body: const StudentCardList(),
      ),
    );
  }
}

class StudentCardList extends StatelessWidget {

  const StudentCardList({super.key});

  // get children => null;

  Future<List<Member>> loadMemberList() async {
    // assetsからJSONファイルを読み込み
    final String response = await rootBundle.loadString('assets/Database.json');
    final data = json.decode(response); // JSONデータをデコード
    List<dynamic> membersJson = data;
    
    // 各メンバーのデータをMemberオブジェクトに変換してリストにする
    return membersJson.map((json) => Member.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {

    final  Future<List<Member>>  students = loadMemberList();

    return FutureBuilder<List>(
        future: students, // Future<T> 型を返す非同期処理
        builder: (BuildContext context, AsyncSnapshot<List> snapshot){

        
          List<Widget> children;
    
          
          if (snapshot.hasData) { // 値が存在する場合の処理
          return ListView.builder(
             itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data![index]['name']!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("学籍番号: ${snapshot.data![index]['student_id']}"),
                Text("大学: ${snapshot.data![index]['university']}"),
                Text("学部: ${snapshot.data![index]['faculty']}"),
              ],
            ),
          ),
        );
      },
          );
         
          } else if (snapshot.hasError) {// エラーが発生した場合の処理
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              ),
            ];
          } else { // 値が存在しない場合の処理
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              ),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      
    );
  
  
  }
}

extension on Future<List<Member>> {
}