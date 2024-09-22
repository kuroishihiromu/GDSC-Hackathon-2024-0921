import 'package:flutter/material.dart';
import 'package:flutter_application_1/infrastructure/upload.dart';
class UploadButton extends StatelessWidget {
  const UploadButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // モックデータをFirestoreに保存
        // storeMockDataInFirestore();
      },
      child: const Text('Upload Mock Data'),
    );
  }
}
