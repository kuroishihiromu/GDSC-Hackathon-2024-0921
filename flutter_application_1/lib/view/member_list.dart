import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'Camera.dart'; // Camera.dartをインポート
import 'package:flutter_application_1/infrastructure/remove_button.dart'; // 削除ボタン機能のimport

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  List<String> tabNames = ['TeamA', 'TeamB', 'TeamC']; // 初期タブ名
  List<String> groupIds = []; // FirestoreのグループIDを格納するリスト
  int _currentIndex = 0; // 現在のタブインデックス

  @override
  void initState() {
    super.initState();
    _loadGroupsFromFirestore(); // Firestoreからグループを読み込む
  }

  // Firestoreからグループを読み込む関数
  void _loadGroupsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('groups').get();
    setState(() {
      groupIds = snapshot.docs.map((doc) => doc.id).toList();
      tabNames = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabNames.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('一覧'),
          bottom: TabBar(
            isScrollable: true,
            onTap: (index) {
              setState(() {
                _currentIndex = index; // 現在のタブインデックスを更新
              });
            },
            tabs: tabNames
                .map((tabName) => Tab(child: Text(tabName)))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: tabNames.asMap().entries.map((entry) {
            int index = entry.key;
            String tabName = entry.value;
            
            return StudentCardList(groupId: groupIds[index]); // groupIdを渡す
          }).toList(),
        ),

        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () async {
                // タブを追加するダイアログを表示
                String? newTabName = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    String tabName = '';
                    return AlertDialog(
                      title: const Text("新しいタブを追加"),
                      content: TextField(
                        onChanged: (value) {
                          tabName = value;
                        },
                        decoration: const InputDecoration(
                          hintText: 'タブ名を入力',
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text("キャンセル"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("追加"),
                          onPressed: () {
                            Navigator.of(context).pop(tabName);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (newTabName != null && newTabName.isNotEmpty) {
                  // Firestoreに新しいタブ名を保存
                  var docRef = await FirebaseFirestore.instance.collection('groups').add({
                    'name': newTabName,
                  });

                  setState(() {
                    tabNames.add(newTabName);
                    groupIds.add(docRef.id); // 新しいグループIDを追加
                  });
                }
              },
              tooltip: 'タブを追加',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () async {
                // カメラリストを取得
                final cameras = await availableCameras();
                final firstCamera = cameras.first;

                // 現在のタブのgroupIdを取得
                String currentGroupId = groupIds[_currentIndex]; 
                
                // カメラ画面に遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(camera: firstCamera, groupId: currentGroupId),
                  ),
                );
              },
              tooltip: 'メンバー追加',
              child: const Icon(Icons.add_a_photo),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentCardList extends StatelessWidget {
  final String groupId;
  const StudentCardList({super.key, required this.groupId});

  // Firestoreから学生データをストリームで取得する関数
  Stream<List<QueryDocumentSnapshot>> loadStudentsFromFirestore() {
    return FirebaseFirestore.instance
        .collection('students')
        .where('group_id', isEqualTo: groupId) // group_idでフィルタリング
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: loadStudentsFromFirestore(), // Firestoreからデータをストリームでロード
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
