import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart'; // GenerativeModelのインポート

// APIキーを指定
const String visionApiKey = 'AIzaSyBqSJI4E_lYgN1pJwDmOB_KQ6t-K37s1Dg';
const String generativeAiApiKey = 'AIzaSyD0IUEDUIiUSSB3_IQZ3bY8HUcYcs7_PaI';

// OCR処理
Future<String> performOCR({required String base64Image}) async {
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
  print(response);
  if (response.text != null) {
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
