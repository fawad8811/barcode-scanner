import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullImageViewScreen extends StatelessWidget {
  final String imageUrl;
  final String barcodeValue;

  const FullImageViewScreen(
      {super.key, required this.imageUrl, required this.barcodeValue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Barcodes'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              barcodeValue,
              maxLines: 10,
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Hero(
                tag: 'fullScreenImage',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
