import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteStudent(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(documentId).delete();
      if (kDebugMode) {
        print('Student with ID $documentId deleted successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting student: $e');
      }
    }
}