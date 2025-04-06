import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _webViewController;
  bool _isLoading = true; // Track loading state
  bool _isOffline = false; // Track offline state
  bool _isConnected = false; // Track internet connection status
  bool _shouldLoadWebView = false; // Track whether WebView should load
  bool _retryInProgress = false; // To prevent retry loop

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _checkConnectivityAndLoadPage();
  }

  // Initialize WebViewController
  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true; // Show loading indicator
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false; // Hide loading indicator after page finishes
            });
          },
          onWebResourceError: (error) {
            // Here, we ensure the error page is only shown if we're offline
            if (!_isConnected) {
              setState(() {
                _isOffline = true; // Show custom error page if no internet
              });
            }
          },
        ),
      );
  }

  // Check internet and load WebView or custom error page
  Future<void> _checkConnectivityAndLoadPage() async {
    if (_retryInProgress) return; // Prevent multiple retries at the same time

    setState(() {
      _retryInProgress = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet, show custom error page
      setState(() {
        _isOffline = true;
        _isLoading = false; // Hide loading indicator immediately
        _isConnected = false; // Set connection status to false
      });
    } else {
      // Internet available, load the website in WebView
      setState(() {
        _isOffline = false;
        _isLoading = true;
        _shouldLoadWebView = true;
        _isConnected = true; // Set connection status to true
        _retryInProgress = false;
      });
      _webViewController.loadRequest(Uri.parse('https://ethiojobs.net/jobs'));
    }
  }

  // Retry logic when user taps Retry button on custom error page
  void _retryConnection() {
    _checkConnectivityAndLoadPage(); // Re-check the connectivity and try loading the page again
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Show custom error page if no internet
            if (_isOffline && !_isConnected)
              _buildCustomErrorPage()
            // Show WebView if internet available
            else if (_shouldLoadWebView && _isConnected)
              WebViewWidget(controller: _webViewController),
            // Show loading indicator while page is loading
            if (_isLoading && !_isOffline && _isConnected)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  // Custom error page widget
  Widget _buildCustomErrorPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'No Internet Connection',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _retryConnection, // Retry loading the webpage
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
      return false; // Prevent default back navigation
    }
    return true; // Allow default back navigation
  }
}
