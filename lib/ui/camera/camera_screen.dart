import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameraController = CameraController(
      widget.camera,
      imageFormatGroup: ImageFormatGroup.jpeg,
      ResolutionPreset.medium,
    )..setFlashMode(FlashMode.torch);

    await _cameraController.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Camera Screen')),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              if (isCameraInitialized) CameraPreview(_cameraController),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: _takePicture,
                  child: const Text('Scan Barcode'),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _takePicture() async {
    final image = await _cameraController.takePicture();

    final barcodeData = await _processImage(image);

    Navigator.pop(context, {
      'barcodeValue': barcodeData['barcodeValue'],
      'capturedImage': image,
    });

    uploadImageAndSaveData(barcodeData['barcodeValue'], image);
  }

  Future<Map<String, dynamic>> _processImage(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

    String barcodeValue = '';

    try {
      final barcodes = await barcodeScanner.processImage(inputImage);

      for (Barcode barcode in barcodes) {
        barcodeValue += barcode.displayValue ?? '';
        barcodeValue += ', ';
      }
      if (barcodeValue.isNotEmpty) {
        barcodeValue = barcodeValue.substring(0, barcodeValue.length - 2);
      }
    } catch (e) {
      print('Error processing barcode: $e');
    } finally {
      barcodeScanner.close();
    }

    return {
      'barcodeValue': barcodeValue,
    };
  }

  Future<String> uploadImageToFirebase(XFile image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef =
        storageRef.child('images/${DateTime.now().millisecond}_${image.name}');
    await imageRef.putFile(File(image.path));
    final downloadUrl = await imageRef.getDownloadURL();
    return downloadUrl;
  }

  Future<void> saveToFirestore(String barcodeValue, String imageUrl) async {
    print("Saving to Firestore: $barcodeValue, $imageUrl");
    final collectionRef = FirebaseFirestore.instance.collection('barcodes');

    try {
      await collectionRef.add({
        'barcodeValue': barcodeValue,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Data saved to Firestore successfully.");
    } catch (e) {
      print("Error saving data to Firestore: $e");
    }
  }

  Future<void> uploadImageAndSaveData(String barcodeValue, XFile image) async {
    try {
      if (barcodeValue.isEmpty || barcodeValue == '0') {
        // Fluttertoast.showToast(
        //   msg: 'No barcode detected',
        //   toastLength: Toast.LENGTH_LONG,
        //   gravity: ToastGravity.TOP,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        // );
        return;
      }

      print("Starting uploadImageAndSaveData function...");

      final imageUrl = await uploadImageToFirebase(image);
      print("Image URL: $imageUrl");

      await saveToFirestore(barcodeValue, imageUrl);

      print("Data saved to Firestore successfully.");
    } catch (e) {
      print('Error uploading data to Firebase: $e');
    }
  }
}
