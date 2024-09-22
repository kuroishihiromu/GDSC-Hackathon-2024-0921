// Camera.dart
import 'dart:io';
import 'dart:convert'; // Base64変換に使用
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // 写真を一時保存するために使用
import 'package:path/path.dart' as path; // ファイルパスの操作に使用
import 'package:image/image.dart' as img; // 画像のBase64変換に使用
import 'package:flutter_application_1/scan.dart'; // scan.dart のOCR処理
import 'package:flutter_application_1/infrastructure/upload.dart'; // upload.dart のFirestore処理をインポート

// カメラで写真を撮影するウィジェット
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final String groupId;

  const TakePictureScreen({super.key, required this.camera, required this.groupId});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 写真を撮影し、Base64形式に変換する関数
  Future<void> _takePictureAndConvertToBase64(BuildContext context) async {
    try {
      // カメラコントローラーの初期化を待つ
      await _initializeControllerFuture;

      // 撮影した写真を保存するためのパスを取得
      final tempDir = await getTemporaryDirectory();
      final imagePath = path.join(tempDir.path, '${DateTime.now()}.png');

      // 写真を撮影し、指定されたパスに保存
      await _controller.takePicture().then((XFile file) async {
        if (mounted) {
          // 画像ファイルを読み込んでBase64に変換
          final bytes = await File(file.path).readAsBytes();
          img.Image image = img.decodeImage(bytes)!;
          String base64String = base64Encode(img.encodePng(image));

          // Base64変換後の画像を表示
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DisplayPictureScreen(base64Image: base64String, groupId: widget.groupId),
            ),
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カメラで撮影')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _takePictureAndConvertToBase64(context),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// 撮影した画像を表示し、OCR処理を実行するウィジェット
class DisplayPictureScreen extends StatefulWidget {
  final String base64Image;

  final String groupId;
  const DisplayPictureScreen({super.key, required this.base64Image, required this.groupId});
  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String _ocrResult = '';
  bool _loading = false;
  Map<String, String>? _jsonData;

  // OCR処理を実行する関数
  Future<void> _performOCR() async {
    setState(() {
      _loading = true;
      _ocrResult = 'OCR処理中...';
    });

    try {
      // scan.dartのOCR処理を呼び出す
      String ocrResult = await performOCR(base64Image: widget.base64Image);

      // OCR結果をAI解析へ
      String aiResult = await generateAIContent(ocrResult);

      // AI結果をJSONに変換
      Map<String, String> jsonData = convertToJson(aiResult);

      // Firestoreにデータを保存
      // await storeDataInFirestore(jsonData, 'group_id');
      await storeDataInFirestore(jsonData, widget.groupId); // groupIdを渡す

      // 成功時にリストページに戻る
      if (mounted) {
        Navigator.pop(context); // 一つ前の画面に戻る
        Navigator.pop(context);
        // さらに戻りたい場合は、追加でポップを行う
      }


    } catch (e) {
      setState(() {
        _ocrResult = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final decodedImage = base64Decode(widget.base64Image);

    return Scaffold(
      appBar: AppBar(title: const Text('撮影した画像')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.memory(decodedImage),
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const CircularProgressIndicator(),
          if (!_loading)
            Text(
              _ocrResult,
              textAlign: TextAlign.center,
            ),
          if (_jsonData != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('JSONデータ: $_jsonData'),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _performOCR,
            child: const Text('この画像を読みとる'),
          ),
        ],
      ),
    );
  }
}
