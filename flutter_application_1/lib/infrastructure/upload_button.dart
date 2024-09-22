import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
    if (kDebugMode) {
      print('Mock data stored in Firestore successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error storing data in Firestore: $e');
    }
  }
}
