import 'package:flutter/material.dart';
import '../core/core.dart';

/// Info dari admin (diambil dari server). Kalau admin menghapus info di server,
/// info itu hilang dari app saat app dibuka ulang.
class InfoBanner extends StatefulWidget {
  const InfoBanner({super.key});
  @override
  State<InfoBanner> createState() => _InfoBannerState();
}

class _InfoBannerState extends State<InfoBanner> {
  List _news = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await Api.get('/api/news');
      final list = (d['news'] as List?) ?? [];
      if (mounted) setState(() => _news = list.take(3).toList());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_news.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      for (final n in _news)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: GradCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.campaign, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text('${n['title']}', style: const TextStyle(fontWeight: FontWeight.bold))),
              ]),
              if ('${n['body'] ?? ''}'.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('${n['body']}', style: const TextStyle(fontSize: 13)),
              ],
            ]),
          ),
        ),
    ]);
  }
}