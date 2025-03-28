import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadWebPage();
  }

  void _loadWebPage() {
    _webViewController.loadRequest(Uri.parse('https://ethiojobs.net/jobs'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _webViewController),
    );
  }
}