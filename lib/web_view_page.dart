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
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
              _hasError = false; // Reset error state on successful load
            });
          },
        ),
      );
    _checkConnectivityAndLoadPage();
  }

  Future<void> _checkConnectivityAndLoadPage() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isLoading = false;
        _hasError = true; // Show custom error page
      });
    } else {
      _loadWebPage(); // Load the web page if connected
    }
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
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            if (_hasError) // Display custom error page
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    SizedBox(
                      height: 57,
                      width: 290,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.asset(
                          'assets/404page.svg',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Text(
                      'No Internet Connection',
                      style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 25),
                    Text(
                      "We're sorry, but it seems you are offline.\nPlease check your internet connection.",
                      style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w200),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false; // Reset the error state
                          _isLoading = true; // Show loading indicator
                          _checkConnectivityAndLoadPage(); // Check connectivity again
                        });
                      },
                      icon: Icon(Icons.refresh, color: Color.fromARGB(255, 72, 193, 156)), // Reload icon
                      label: Text("Retry", style: TextStyle(color: Color.fromARGB(255, 72, 193, 156))), // Label text
                    ),
                  ],
                ),
              )
            else
              WebViewWidget(controller: _webViewController),
            if (_isLoading && !_hasError)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}