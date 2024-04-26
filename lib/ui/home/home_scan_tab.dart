import 'dart:io';
import 'package:barcode_scanner/ui/camera/camera_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScanTab extends StatefulWidget {
  final CameraDescription camera;

  const ScanTab({super.key, required this.camera});

  @override
  ScanTabState createState() => ScanTabState();
}

class ScanTabState extends State<ScanTab> {
  String barcodeValue = '';
  XFile? capturedImage;

  Future<void> navigateToCameraScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: widget.camera),
      ),
    );

    if (result != null) {
      setState(() {
        barcodeValue = result['barcodeValue'] ?? 'null';
        capturedImage = result['capturedImage'];
      });

      if (barcodeValue == 'null' || barcodeValue.isEmpty) {
        Fluttertoast.showToast(
          msg: 'No barcode value detected',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
              text: TextSpan(
                  text: 'Barcode Value: ',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                TextSpan(
                    text: barcodeValue,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.purple,
                        fontSize: 16))
              ])),
        ),
        if (capturedImage != null) Image.file(File(capturedImage!.path)),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: navigateToCameraScreen,
            child: const Text(
              'Scan Barcode',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
