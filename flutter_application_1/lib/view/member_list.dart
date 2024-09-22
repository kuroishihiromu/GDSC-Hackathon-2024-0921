import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'Camera.dart'; // Camera.dartをインポート
import 'package:flutter_application_1/infrastructure/remove_button.dart'; // 削除ボタン機能のimport

class MemberList extends StatelessWidget {
  const MemberList({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
            StudentCardList(), // Team Aのデータを表示
            Center(child: Text("Team B の情報がここに表示されます。")),
            Center(child: Text("Team C の情報がここに表示されます。")),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // カメラリストを取得
            final cameras = await availableCameras();
            final firstCamera = cameras.first;

            // カメラ画面に遷移
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TakePictureScreen(camera: firstCamera),
              ),
            );
          },
          tooltip: 'メンバー追加',
          child: const Icon(Icons.add_a_photo),
        ),
      ),
    );
  }
}

class StudentCardList extends StatelessWidget {
  const StudentCardList({super.key});

  // Firestoreから学生データを取得する関数
  Future<List<QueryDocumentSnapshot>> loadStudentsFromFirestore() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('students').where('isDeleted',isEqualTo: false).get();
      return snapshot.docs;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading students from Firestore: $e');
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: loadStudentsFromFirestore(), // Firestoreからデータをロード
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No students found.'));
        } else {
          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var studentData = students[index].data() as Map<String, dynamic>;
              var documentId = students[index].id; // ドキュメントIDを取得

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentData['name'] ?? 'No Name',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("学籍番号: ${studentData['student_id'] ?? 'N/A'}"),
                            Text("大学: ${studentData['university_name'] ?? 'N/A'}"),
                            Text("学部: ${studentData['faculty'] ?? 'N/A'}"),
                            Text("学科: ${studentData['department'] ?? 'N/A'}"),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("削除確認"),
                                    content: const Text("この学生を削除しますか？"),
                                    actions: [
                                      TextButton(
                                        child: const Text("キャンセル"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text("削除"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (confirmDelete) {
                            await deleteStudent(documentId); // 学生データを削除
                          }
                        },
                      ),
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