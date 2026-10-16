import 'package:flutter/material.dart';
import '../core/core.dart';
import 'tool_tile.dart';
import 'web_page.dart';

const _cats = ['ALAT BARU', 'Unduh', 'Media', 'Teks', 'Alat', 'Lainnya'];

const _webItems = [
  {'name': 'AM PREMIUM 1 TAHUN', 'desc': 'Buka di dalam aplikasi', 'url': 'https://adamnurs.my.id'},
  {'name': 'AM GRATIS 1 THN', 'desc': 'Buka di dalam aplikasi', 'url': 'https://am-premiumms.vercel.app/'},
  {'name': 'TikTok', 'desc': 'Scroll di dalam aplikasi', 'url': 'https://www.tiktok.com'},
  {'name': 'YouTube', 'desc': 'Tonton di dalam aplikasi', 'url': 'https://m.youtube.com'},
];

/// Menentukan kategori tab untuk setiap fitur dari server.
String catOf(Map t) {
  final id = '${t['id']}';
  final route = '${t['route']}';
  if (id.startsWith('dl_')) return 'Unduh';
  if (t['kind'] == 'app') {
    switch (route) {
      case 'sw_wa':
      case 'amzarvida':
        return 'Media';
      case 'ocr':
      case 'tts':
      case 'stt':
        return 'Teks';
      default:
        return 'Alat';
    }
  }
  switch (id) {
    case 'preset':
      return 'Media';
    case 'styleteks':
    case 'translate':
    case 'json':
    case 'uuid':
      return 'Teks';
    case 'nik':
    case 'password':
    case 'qr':
    case 'ipwho':
    case 'cek':
    case 'jodoh':
      return 'Alat';
  }
  return 'Lainnya';
}

Widget _tile(
  BuildContext c, {
  required IconData icon,
  required String title,
  required String desc,
  required VoidCallback onTap,
  Widget? trailing,
  bool dim = false,
}) =>
    Opacity(
      opacity: dim ? 0.5 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, size: 28),
                const Spacer(),
                if (trailing != null) trailing,
              ]),
              const SizedBox(height: 10),
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Expanded(
                child: Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ]),
          ),
        ),
      ),
    );

class FeaturesTab extends StatelessWidget {
  const FeaturesTab({super.key});

  @override
  Widget build(BuildContext context) => Loader(
        load: () => Api.get('/api/tools'),
        build: (c, d, r) {
          final tools = (d['tools'] as List).cast<Map>();
          final byCat = <String, List<Map>>{for (final k in _cats) k: []};
          for (final t in tools) {
            (byCat[catOf(t)] ?? byCat['Lainnya']!).add(t);
          }
          return DefaultTabController(
            length: _cats.length,
            child: Column(children: [
              TabBar(
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF606070), Color(0xFF9664E6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: const [BoxShadow(color: Color(0x88AA6EFF), blurRadius: 12, spreadRadius: 1)],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF8E8E9E),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Color(0xFFAA6EFF), blurRadius: 8)],
                ),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                tabs: [for (final k in _cats) Tab(text: k)],
              ),
              Expanded(
                child: TabBarView(children: [
                  _webGrid(c),
                  for (final k in _cats.skip(1)) _grid(c, byCat[k]!, r),
                ]),
              ),
            ]),
          );
        },
      );

  Widget _webGrid(BuildContext c) => GridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.05,
        children: [
          for (final w in _webItems)
            _tile(
              c,
              icon: Icons.public,
              title: w['name']!,
              desc: w['desc']!,
              onTap: () => openWeb(c, w['name']!, w['url']!),
            ),
        ],
      );

  Widget _grid(BuildContext c, List<Map> items, VoidCallback r) => items.isEmpty
      ? const Center(child: Text('Belum ada fitur di kategori ini'))
      : GridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.05,
          children: [
            for (final t in items)
              _tile(
                c,
                icon: t['suspended'] == true ? Icons.pause_circle : toolIcon(t['icon']),
                title: '${t['name']}',
                desc: t['suspended'] == true ? 'Dinonaktifkan' : '${t['desc']}',
                dim: t['suspended'] == true,
                trailing: IconButton(
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(t['fav'] == true ? Icons.star : Icons.star_border),
                  onPressed: () async {
                    try {
                      await Api.post('/api/favorites/${t['id']}');
                      r();
                    } catch (_) {}
                  },
                ),
                onTap: () async {
                  await openTool(c, t);
                  r();
                },
              ),
          ],
        );
}