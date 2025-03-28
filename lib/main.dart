 // Import the new file
import 'package:ethiojobs_webview/web_view_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EthioJobs',
      debugShowCheckedModeBanner: false,
      home: WebViewPage(), // Use the new WebViewPage
    );
  } 
}
