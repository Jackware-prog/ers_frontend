import 'package:flutter/material.dart';

class FullScreenMediaView extends StatelessWidget {
  final String mediaUrl;

  const FullScreenMediaView({Key? key, required this.mediaUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(mediaUrl),
      ),
    );
  }
}
