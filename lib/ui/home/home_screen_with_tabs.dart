import 'package:barcode_scanner/ui/home/home_barcode_list_tab.dart';
import 'package:barcode_scanner/ui/home/home_scan_tab.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Barcode Scanner'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Scan'),
                Tab(text: 'List'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ScanTab(camera: camera),
              const ListTab(),
            ],
          ),
        ),
      ),
    );
  }
}
