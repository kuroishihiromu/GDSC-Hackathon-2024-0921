import 'package:cloud_firestore/cloud_firestore.dart';

// モックデータを用意
Map<String, dynamic> mockUserData = {
  'student_id': '123456',
  'name': 'John Doe',
  'faculty': 'Engineering',
  'department': 'Computer Science',
  'university_name': 'Tokyo University',
};

// Firestoreにモックデータを格納する関数
Future<void> storeMockDataInFirestore() async {
  try {
    // Firestoreにモックデータを格納
    await FirebaseFirestore.instance.collection('students').add(mockUserData);
    print('Mock data stored in Firestore successfully');
  } catch (e) {
    print('Error storing data in Firestore: $e');
  }
}
