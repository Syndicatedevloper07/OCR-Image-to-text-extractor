import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:imagetotext/myhomepage.dart';
import 'package:translator/translator.dart';

class Textextractor extends StatefulWidget {
  const Textextractor({super.key});

  @override
  State<Textextractor> createState() => _TextextractorState();
}

class _TextextractorState extends State<Textextractor> {
  String extractedText = '';
  bool isExtracting = false;

  Future<void> readTextFromImage() async {
    setState(() {
      isExtracting = true;
    });

    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;

    textRecognizer.close();
    setState(() {
      extractedText = text;
      isExtracting = false;
    });

    // Disable the button for 2 seconds
    Timer(Duration(seconds: 2), () {
      setState(() {
        isExtracting = false;
      });
    });
  }

  File? _image;
  final picker = ImagePicker();
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: getImageFromGallery,
            icon: Icon(
              Icons.add_a_photo_rounded,
              size: 30,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 15,
          )
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Myhomepage();
              }));
            },
            icon: Icon(Icons.arrow_back)),
        centerTitle: true,
        title: Text(
          'Text Extractor',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: _image == null
            ? Center(child: Text('Select an Image'))
            : Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 320,
                        width: 320,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 60,
                        width: 320,
                        child: ElevatedButton(
                          onPressed: isExtracting ? null : readTextFromImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isExtracting
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Extract Text",
                                  style: TextStyle(
                                    fontSize: 21,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 150,
                        width: 320,
                        decoration: ShapeDecoration(
                          color: Colors.blue[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              extractedText,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 130,
                            child: ElevatedButton(
                              onPressed: () async {
                                final translation = await extractedText
                                    .translate(from: 'en', to: 'ml');

                                setState(() {
                                  extractedText = translation.text;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Translate",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          SizedBox(
                            height: 50,
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: extractedText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Text copied to clipboard'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Copy",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: getImageFromGallery,
      //   tooltip: 'Select Image',
      //   child: Icon(Icons.image),
      // ),
    );
  }
}
