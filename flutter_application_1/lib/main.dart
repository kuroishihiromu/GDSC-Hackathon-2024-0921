import 'package:flutter/material.dart';
import 'dart:typed_data'; // Uint8Listのためにインポート
import 'scan.dart'; // scan.dartから関数をインポート

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '学生証 OCR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(), // メイン画面としてMyHomePageを表示
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _imageBytes;
  String _scannedText = 'ここにOCRで読み取ったテキストが表示されます';

  // スキャン処理をscan.dartから呼び出す
  Future<void> _pickImage() async {
    final Uint8List? imageBytes = await performImageScan(); // scan.dartの関数を使用
    if (imageBytes != null) {
      setState(() {
        _imageBytes = imageBytes;
      });
      await _performOCR(_imageBytes!);
    }
  }

  // OCR処理を実行
  Future<void> _performOCR(Uint8List imageBytes) async {
    final String scannedText = await performOCR(imageBytes); // scan.dartのOCR処理を呼び出し
    setState(() {
      _scannedText = scannedText.isNotEmpty ? scannedText : 'テキストが検出されませんでした。';
    });
    await _generateContent(_scannedText); // 生成AIモデルにOCR結果を渡す
  }

  // 生成AIを用いてOCR結果を解析
  Future<void> _generateContent(String scannedText) async {
    final String generatedContent = await generateAIContent(scannedText); // scan.dartの生成AI関数を呼び出し
    print(generatedContent); // 生成された内容をコンソールに表示
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学生証 OCR'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _imageBytes != null
                  ? Image.memory(
                      _imageBytes!,
                      fit: BoxFit.contain,
                    )
                  : const Placeholder(fallbackHeight: 200, fallbackWidth: double.infinity),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('ファイルを選択'),
              ),
              const SizedBox(height: 16),
              const Text(
                '認識結果:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(_scannedText),
            ],
          ),
        ),
      ),
    );
  }
}
