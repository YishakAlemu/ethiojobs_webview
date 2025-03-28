import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _webViewController;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false; // Page has finished loading
            });
          },
        ),
      );
    _loadWebPage();
  }

  void _loadWebPage() {
    _webViewController.loadRequest(Uri.parse('https://ethiojobs.net/jobs'));
  }

  Future<bool> _onWillPop() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
      return false; // Prevent the default back navigation
    }
    return true; // Allow the default back navigation
  }

  @override
  Widget build(BuildContext context) {   
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading) // Show loading indicator when loading
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}