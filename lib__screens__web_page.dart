import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Membuka website langsung di dalam app (tanpa browser luar).
class WebPage extends StatefulWidget {
  final String title;
  final String url;
  const WebPage({super.key, required this.title, required this.url});
  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  late final WebViewController _c;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _back() async {
    if (await _c.canGoBack()) {
      await _c.goBack();
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: () => _c.reload()),
            ],
          ),
          body: Column(children: [
            if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
            Expanded(child: WebViewWidget(controller: _c)),
          ]),
        ),
      );
}

/// Dipanggil dari menu untuk membuka halaman web di dalam app.
void openWeb(BuildContext c, String title, String url) {
  Navigator.push(c, MaterialPageRoute(builder: (_) => WebPage(title: title, url: url)));
}