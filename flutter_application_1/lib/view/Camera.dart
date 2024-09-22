import 'dart:io';
import 'dart:convert'; // Base64変換に使用
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // 写真を一時保存するために使用
import 'package:path/path.dart'; // ファイルパスの操作に使用
import 'package:image/image.dart' as img; // 画像のBase64変換に使用

// カメラで写真を撮影するウィジェット
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({super.key, required this.camera});

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
      ResolutionPreset.low,
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
      final imagePath = join(tempDir.path, '${DateTime.now()}.png');

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
              builder: (context) => DisplayPictureScreen(base64Image: base64String),
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

// 撮影した画像を表示するウィジェット
class DisplayPictureScreen extends StatelessWidget {
  final String base64Image;

  const DisplayPictureScreen({super.key, required this.base64Image});

  @override
  Widget build(BuildContext context) {
    // Base64の文字列をデコードして画像に変換
    final decodedImage = base64Decode(base64Image);

    return Scaffold(
      appBar: AppBar(title: const Text('撮影した画像')),
      body: Center(
        child: Image.memory(decodedImage),
      ),
    );
  }
}

