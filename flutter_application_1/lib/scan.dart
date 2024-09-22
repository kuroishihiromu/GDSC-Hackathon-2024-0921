import 'dart:async'; // Completerのためのインポート
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // 画像選択用パッケージ
import 'package:google_generative_ai/google_generative_ai.dart'; // GenerativeModelのインポート

// OCRと生成AI用のAPIキーを指定
const String visionApiKey = 'AIzaSyAKM3WhkIQeaWEO5azcIwTfS1fmwr-lymI';
const String generativeAiApiKey = 'AIzaSyDL5yYRQS93_x1dt-6OQvhNZ-Wk_VTcgWI';

// 画像選択処理
Future<Uint8List?> performImageScan() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    return await pickedFile.readAsBytes();
  } else {
    return null;
  }
}

// OCR処理
Future<String> performOCR(Uint8List imageBytes) async {
  final String base64Image = base64Encode(imageBytes);
  final Map<String, dynamic> requestData = {
    'requests': [
      {
        'image': {
          'content': base64Image,
        },
        'features': [
          {
            'type': 'TEXT_DETECTION',
          }
        ]
      }
    ]
  };

  const String url = 'https://vision.googleapis.com/v1/images:annotate?key=$visionApiKey';

  final http.Response response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(requestData),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['responses'] != null && data['responses'][0]['textAnnotations'] != null) {
      return data['responses'][0]['textAnnotations'][0]['description'];
    } else {
      return 'テキストが検出されませんでした。';
    }
  } else {
    return 'OCRの処理中にエラーが発生しました。';
  }
}

// 生成AIによるコンテンツ生成
Future<String> generateAIContent(String scannedText) async {
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: generativeAiApiKey);
  final content = [
    Content.text('以下の情報をコンマ区切り（スペースなし）で、順番に抽出してください: university_name, student_id, name, faculty: $scannedText')
  ];

  final response = await model.generateContent(content);
  if (response.text != null) {
    // 生成されたコンテンツをデバッグ用に表示
    print('Generated AI Content: ${response.text}');
    return response.text!;
  } else {
    return '生成されたコンテンツがありません。';
  }
}

// スキャンしたテキストをJSON形式に変換
Map<String, String> convertToJson(String data) {
  // 文字列をスプリット
  List<String> splitData = data.split(',');

  // スプリットしたデータをJSON形式に変換
  Map<String, String> jsonData = {
    'university_name': splitData[0],
    'student_id': splitData[1],
    'name': splitData[2],
    'faculty': splitData[3]
  };

  // デバッグ用出力（生成されたJSONデータを表示）
  print('Generated JSON data: $jsonData');

  return jsonData;
}

