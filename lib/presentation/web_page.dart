import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/asset_server.dart';

class WebPage extends StatefulWidget {
  const WebPage({
    super.key,
    required this.title,
    required this.url,
    this.localChart = false,
  });
  final String title;
  final String url;
  final bool localChart;
  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  WebViewController? _controller;
  final _assets = AssetServer();
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var uri = Uri.parse(widget.url);
      if (widget.localChart) uri = await _assets.start(uri.query);
      if (!mounted) {
        await _assets.close();
        return;
      }
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              final scheme = Uri.tryParse(request.url)?.scheme;
              return scheme == 'http' || scheme == 'https'
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent;
            },
            onPageStarted: (_) {
              if (mounted)
                setState(() {
                  _loading = true;
                  _error = null;
                });
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (error) {
              if (mounted && error.isForMainFrame == true) {
                setState(() {
                  _loading = false;
                  _error = '页面加载失败，请重试';
                });
              }
            },
          ),
        );
      setState(() => _controller = controller);
      await controller.loadRequest(uri);
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = '无法打开页面';
        });
    }
  }

  @override
  void dispose() {
    unawaited(_assets.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: SafeArea(
      child: Stack(
        children: [
          if (_controller case final controller?)
            WebViewWidget(controller: controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error case final error?)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error),
                      TextButton(
                        onPressed: () async {
                          if (_controller != null) {
                            await _controller!.reload();
                          } else {
                            await _assets.close();
                            if (mounted) await _load();
                          }
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: '后退',
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final controller = _controller;
              if (controller != null && await controller.canGoBack())
                await controller.goBack();
            },
          ),
          IconButton(
            tooltip: '前进',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              final controller = _controller;
              if (controller != null && await controller.canGoForward())
                await controller.goForward();
            },
          ),
          IconButton(
            tooltip: '关闭',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}
