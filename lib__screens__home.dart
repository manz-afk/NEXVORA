import 'package:flutter/material.dart';
import '../core/core.dart';
import 'dash_tab.dart';
import 'features_tab.dart';
import 'search_tab.dart';
import 'favorites_tab.dart';
import 'account_tab.dart';
import 'update_check.dart';
import '../core/widget_sync.dart';

const _teal = Color(0xFF2A8C86);
const _ink = Color(0xFF111111);
const _gold = Color(0xFFF5A623);
const _cream = Color(0xFFF4EFE6);

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int i = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUpdate(context);
      syncWidget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pages = [
      DashTab(onGo: (v) => setState(() => i = v)),
      const FeaturesTab(),
      const SearchTab(),
      const FavoritesTab(),
      const AccountTab(),
    ];
    return Scaffold(
      backgroundColor: dark ? null : _cream,
      appBar: i == 0
          ? null
          : AppBar(
              backgroundColor: dark ? null : _cream,
              title: Text(['Beranda', 'Fitur', 'Cari', 'Favorit', 'Akun'][i]),
            ),
      body: SafeArea(
        top: i == 0,
        bottom: false,
        child: Column(children: [
          ValueListenableBuilder<bool>(
            valueListenable: Api.fromCache,
            builder: (c, v, _) => v
                ? Container(
                    width: double.infinity,
                    color: Colors.orange.withOpacity(0.2),
                    padding: const EdgeInsets.all(6),
                    child: const Text('Mode offline: menampilkan data terakhir', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(child: pages[i]),
        ]),
      ),
      bottomNavigationBar: _BottomBar(index: i, onTap: (v) => setState(() => i = v)),
    );
  }
}

/// Navigasi bawah melayang dengan tombol bulat di tab aktif.
class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  static const _icons = [Icons.home_rounded, Icons.apps_rounded, Icons.search_rounded, Icons.star_rounded, Icons.person_rounded];
  static const _labels = ['HOME', 'FITUR', 'CARI', 'FAVORIT', 'AKUN'];

  Widget _item(BuildContext c, int k) {
    final sel = k == index;
    final dark = Theme.of(c).brightness == Brightness.dark;
    final fg = dark ? Colors.white70 : Colors.black54;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(k),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          sel
              ? Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold,
                    border: Border.all(color: _ink, width: 3),
                    boxShadow: const [BoxShadow(color: _teal, offset: Offset(2, 2))],
                  ),
                  child: Icon(_icons[k], color: _ink, size: 26),
                )
              : Icon(_icons[k], color: fg, size: 24),
          const SizedBox(height: 4),
          Text(
            _labels[k],
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1, color: sel ? (dark ? Colors.white : _ink) : fg),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: SizedBox(
          height: 84,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 62,
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF17171B) : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: dark ? const Color(0xFF3A3A44) : _ink, width: 2.5),
                  boxShadow: const [BoxShadow(color: _teal, offset: Offset(4, 4))],
                ),
              ),
            ),
            Positioned.fill(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var k = 0; k < 5; k++) Expanded(child: _item(context, k)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}