import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/menu.dart';
import '../models/question.dart';
import '../services/photoGallery.dart';
import '../presentation/web_page.dart';

class PhotoGalleryList extends StatefulWidget {
  const PhotoGalleryList({super.key, required this.reportType});
  final Menu reportType;
  @override
  State<PhotoGalleryList> createState() => _PhotoGalleryListState();
}

class _PhotoGalleryListState extends State<PhotoGalleryList> {
  final _textController = TextEditingController();
  List<Question> _items = [];
  final Map<String, List<Question>> _previews = {};
  bool _loading = true;
  bool _failed = false;
  bool _downloading = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final items = await PhotoGalleryService.getList(widget.reportType.url);
      if (!mounted || generation != _generation) return;
      setState(() {
        _items = items;
        _loading = false;
        _previews.clear();
      });
      // Fetch previews once per response, never as a side effect of build().
      for (final item in items.where(
        (item) => item.zhihuLink.contains('answer') && !_isImage(item.link),
      )) {
        try {
          final preview = await PhotoGalleryService.getList(item.link);
          if (!mounted || generation != _generation) return;
          setState(() => _previews[item.link] = preview);
        } on Exception {
          /* A missing preview does not hide the gallery. */
        }
      }
    } on Exception {
      if (mounted && generation == _generation)
        setState(() {
          _loading = false;
          _failed = true;
        });
    }
  }

  bool _isImage(String url) => RegExp(
    r'\.(jpe?g|png|webp|gif)$',
    caseSensitive: false,
  ).hasMatch(Uri.tryParse(url)?.path ?? '');
  void _message(String message) {
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    final result = await PhotoGalleryService.downloadDetail(
      _textController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _downloading = false);
    _message(result ? '已提交下载请求' : '下载请求失败，请检查链接及网络');
  }

  Future<void> _openImage(String link) async {
    try {
      final uri = Uri.parse(link);
      if (!['http', 'https'].contains(uri.scheme) ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _message('无法打开图片');
      }
    } on Exception {
      _message('无法打开图片');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.reportType.name)),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _failed
                ? Center(
                    child: TextButton(
                      onPressed: _fetch,
                      child: const Text('加载失败，点击重试'),
                    ),
                  )
                : _items.isEmpty
                ? const Center(child: Text('暂无图片'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isTag = item.tag.isNotEmpty;
                      final title = isTag
                          ? '${item.tag}[${item.total}]'
                          : item.key.replaceFirst(
                              'resources/zhihu-images/',
                              '',
                            );
                      final link = isTag ? item.imageRecords : item.link;
                      final preview = _previews[link];
                      final image = _isImage(link)
                          ? link
                          : (preview != null && preview.isNotEmpty
                                ? preview.first.link
                                : null);
                      return Card(
                        margin: const EdgeInsets.all(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (preview != null)
                                Text('共 ${preview.length} 张'),
                              if (image != null)
                                ExtendedImage.network(
                                  image,
                                  height: 400,
                                  fit: BoxFit.contain,
                                  cache: true,
                                ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_isImage(link)) {
                                        _openImage(link);
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PhotoGalleryList(
                                              reportType: Menu(
                                                url: link,
                                                name: title,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(_isImage(link) ? '打开原图' : '打开'),
                                  ),
                                  if (item.zhihuLink.isNotEmpty)
                                    ElevatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => WebPage(
                                            title: '知乎',
                                            url: item.zhihuLink,
                                          ),
                                        ),
                                      ),
                                      child: const Text('打开知乎'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          ExpansionTile(
            title: const Text('下载相簿'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: '相簿链接',
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: IconButton(
                      onPressed: _textController.clear,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _downloading ? null : _download,
                child: Text(_downloading ? '提交中…' : '下载'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
