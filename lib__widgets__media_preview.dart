import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PreviewKind { video, audio, image, none }

/// Menentukan jenis pratinjau dari alamat file, atau dari label kalau alamatnya tidak jelas.
PreviewKind previewKindOf(String url, String label) {
  final u = url.toLowerCase().split('?').first;
  if (RegExp(r'\.(mp4|webm|mov|mkv)$').hasMatch(u)) return PreviewKind.video;
  if (RegExp(r'\.(mp3|m4a|wav|ogg)$').hasMatch(u)) return PreviewKind.audio;
  if (RegExp(r'\.(jpg|jpeg|png|webp|gif)$').hasMatch(u)) return PreviewKind.image;
  final l = label.toLowerCase();
  if (l.contains('mp3') || l.contains('musik') || l.contains('audio')) return PreviewKind.audio;
  if (l.contains('mp4') || l.contains('video')) return PreviewKind.video;
  if (l.contains('foto')) return PreviewKind.image;
  return PreviewKind.none;
}

/// Pratinjau di dalam app: video/audio diputar lewat WebView, gambar lewat Image.network.
class MediaPreview extends StatefulWidget {
  final String url;
  final PreviewKind kind;
  const MediaPreview({super.key, required this.url, required this.kind});
  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  WebViewController? _c;

  @override
  void initState() {
    super.initState();
    if (widget.kind == PreviewKind.video || widget.kind == PreviewKind.audio) {
      final src = const HtmlEscape().convert(widget.url);
      final tag = widget.kind == PreviewKind.video
          ? '<video controls playsinline style="width:100%;height:100%;background:#000" src="$src"></video>'
          : '<audio controls style="width:100%" src="$src"></audio>';
      final html = '<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1">'
          '<style>html,body{margin:0;height:100%;background:#000;display:flex;align-items:center;justify-content:center}</style>'
          '</head><body>$tag</body></html>';
      _c = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF000000))
        ..loadHtmlString(html);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.kind) {
      case PreviewKind.video:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(height: 220, child: WebViewWidget(controller: _c!)),
        );
      case PreviewKind.audio:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(height: 60, child: WebViewWidget(controller: _c!)),
        );
      case PreviewKind.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.url,
            height: 220,
            width: double.infinity,
            fit: BoxFit.contain,
            loadingBuilder: (c, child, p) => p == null ? child : const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
            errorBuilder: (_, __, ___) => const SizedBox(height: 60, child: Center(child: Text('Pratinjau gagal dimuat'))),
          ),
        );
      case PreviewKind.none:
        return const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Pratinjau tidak tersedia untuk jenis file ini. Gunakan tombol Simpan.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        );
    }
  }
}