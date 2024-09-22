import 'package:cloud_firestore/cloud_firestore.dart';

// Firestoreにデータを格納する関数
Future<void> storeDataInFirestore(Map<String, dynamic> jsonData, String groupId) async {
  try {
    // group_idをjsonDataに追加
    jsonData['group_id'] = groupId;

    // Firestoreに渡されたJSONデータを格納
    await FirebaseFirestore.instance.collection('students').add(jsonData);
    print('Data stored in Firestore successfully');
  } catch (e) {
    print('Error storing data in Firestore: $e');
  }
}
