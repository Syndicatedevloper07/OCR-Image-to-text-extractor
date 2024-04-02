import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:translator/translator.dart';

class CameraTranslationPage extends StatefulWidget {
  @override
  _CameraTranslationPageState createState() => _CameraTranslationPageState();
}

class _CameraTranslationPageState extends State<CameraTranslationPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  String _translatedText = '';
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _startScanning() {
    _cameraController.startImageStream((CameraImage image) {
      // You can process the image here and use ML Kit or other libraries to extract text
      // For simplicity, let's assume we have the text already extracted
      String extractedText =
          'Hello'; // Replace this with actual text extraction logic

      _translateText(extractedText);
    });
  }

  Future<void> _translateText(String text) async {
    Translation translation =
        await _translator.translate(text, from: 'en', to: 'ml');
    setState(() {
      _translatedText = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Translation'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                _cameraController.value.isInitialized
                    ? CameraPreview(_cameraController)
                    : Container(),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    _translatedText,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScanning,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
