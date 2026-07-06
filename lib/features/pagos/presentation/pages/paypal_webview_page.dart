import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PaypalWebviewResult { approved, cancelled }

class PaypalWebviewPage extends StatefulWidget {
  final String approveUrl;

  const PaypalWebviewPage({super.key, required this.approveUrl});

  @override
  State<PaypalWebviewPage> createState() => _PaypalWebviewPageState();
}

class _PaypalWebviewPageState extends State<PaypalWebviewPage> {
  static const _returnUrlPrefix = 'https://redayuda.app/paypal-return';
  static const _cancelUrlPrefix = 'https://redayuda.app/paypal-cancel';

  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            if (request.url.startsWith(_returnUrlPrefix)) {
              Navigator.pop(context, PaypalWebviewResult.approved);
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith(_cancelUrlPrefix)) {
              Navigator.pop(context, PaypalWebviewResult.cancelled);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approveUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar con PayPal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, PaypalWebviewResult.cancelled),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
