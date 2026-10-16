import 'dart:async';
import 'package:flutter/material.dart';
import '../core/core.dart';

// ====== PENGATURAN TAMPILAN (ubah di sini kalau perlu) ======
const _teal = Color(0xFF2A8C86);
const _ink = Color(0xFF111111);
const _invert = true; // true = gambar logo dibalik jadi putih di latar hitam. Kalau fotomu sudah gelap, ganti false.
const _invertMatrix = <double>[
  -1.0, 0.0, 0.0, 0.0, 255.0,
  0.0, -1.0, 0.0, 0.0, 255.0,
  0.0, 0.0, -1.0, 0.0, 255.0,
  0.0, 0.0, 0.0, 1.0, 0.0,
];

Widget _art({BoxFit fit = BoxFit.contain, Alignment alignment = Alignment.center, double? w, double? h}) {
  final img = Image.asset('assets/logo.png', fit: fit, alignment: alignment, width: w, height: h);
  return _invert ? ColorFiltered(colorFilter: const ColorFilter.matrix(_invertMatrix), child: img) : img;
}

const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
String _hm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
String _dateStr(DateTime t) => '${_days[t.weekday - 1]}, ${t.day} ${_months[t.month - 1]} ${t.year}';

/// Kartu dengan garis tebal dan bayangan keras.
class _Thick extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final double shadow;
  const _Thick({required this.child, this.padding = const EdgeInsets.all(14), this.radius = 16, this.shadow = 3});
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 4, shadow + 1, shadow + 5),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF17171B) : Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: dark ? const Color(0xFF3A3A44) : _ink, width: 2),
          boxShadow: [BoxShadow(color: _teal, offset: Offset(shadow, shadow))],
        ),
        child: child,
      ),
    );
  }
}

/// Jam yang diperbarui otomatis.
class _Clock extends StatefulWidget {
  final Widget Function(DateTime now) builder;
  const _Clock({required this.builder});
  @override
  State<_Clock> createState() => _ClockState();
}

class _ClockState extends State<_Clock> {
  DateTime now = DateTime.now();
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(now);
}

class DashTab extends StatelessWidget {
  final void Function(int)? onGo;
  const DashTab({super.key, this.onGo});

  static const _grey = TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.grey);

  Widget _header(BuildContext c, String name) {
    final off = Api.fromCache.value;
    return Row(children: [
      InkWell(
        onTap: () => onGo?.call(4),
        child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.menu)),
      ),
      const SizedBox(width: 4),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'nexvora', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              TextSpan(text: ' • $name', style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: off ? Colors.orange : const Color(0xFF16C784))),
            const SizedBox(width: 5),
            Text(off ? 'OFFLINE' : 'ONLINE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ]),
        ]),
      ),
      _Clock(
        builder: (t) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_hm(t), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text('${t.day} ${_months[t.month - 1]}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      ),
      IconButton(onPressed: () => onGo?.call(4), icon: const Icon(Icons.palette_outlined, color: _teal)),
    ]);
  }

  Widget _quick(BuildContext c) => GestureDetector(
        onTap: () => onGo?.call(1),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(c).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.5),
          ),
          child: Row(children: [
            const Icon(Icons.apps_rounded, color: _teal),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('NEXVORA FITUR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: _teal)),
                Text('Buka semua fitur dan alat', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      );

  Widget _banner(BuildContext c) => Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 10, top: 6),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF222222), width: 4),
              boxShadow: const [BoxShadow(color: _teal, offset: Offset(8, 8))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(width: double.infinity, height: 230, child: _art(fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            left: 14,
            top: -8,
            child: Transform.rotate(
              angle: -0.06,
              child: Container(
                color: _teal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: const Text('NEXVORA // MAIN HQ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
              ),
            ),
          ),
        ]),
      );

  Widget _wstat(String label, Widget value, {CrossAxisAlignment al = CrossAxisAlignment.start}) => Column(
        crossAxisAlignment: al,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white54)),
          const SizedBox(height: 4),
          value,
        ],
      );

  Widget _welcome(BuildContext c, String name, String id, String role, bool off) {
    const w = TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14);
    final shortId = id.length > 2 ? id.substring(0, 2) : id;
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 12),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _ink, width: 2),
          boxShadow: const [BoxShadow(color: _teal, offset: Offset(5, 5))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(fit: StackFit.expand, children: [
            _art(fit: BoxFit.cover, alignment: const Alignment(0.7, -0.5)),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xF2000000), Color(0x55000000)]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0x331E7F78), border: Border.all(color: _teal, width: 2)),
                    child: const Icon(Icons.person, color: _teal, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Welcome Back,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                      Text('ID: $shortId***', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ]),
                  ),
                ]),
                const Spacer(),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _wstat('ROLE', Text(role.toUpperCase(), style: w)),
                  _wstat(
                    'STATUS',
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: off ? Colors.orange : const Color(0xFF16C784))),
                      const SizedBox(width: 6),
                      Text(off ? 'Offline' : 'Online', style: w),
                    ]),
                  ),
                  _wstat('NEXVORA', const Text('by manz', style: w), al: CrossAxisAlignment.end),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.45), width: 1.2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(label, style: _grey)),
              Icon(icon, size: 14, color: Colors.grey),
            ]),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          ]),
        ),
      );

  Widget _info(Map d, bool off) => _Thick(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.hub_outlined, size: 16, color: _teal),
            SizedBox(width: 8),
            Text('INFORMASI DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: _teal)),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.45), width: 1.2)),
            child: Row(children: [
              Expanded(
                child: _Clock(
                  builder: (t) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_hm(t), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, height: 1)),
                    const SizedBox(height: 6),
                    Text(_dateStr(t), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.dns_outlined, size: 18, color: _teal),
                  const SizedBox(width: 6),
                  Text(off ? 'OFFLINE' : 'ONLINE', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _teal)),
                ]),
                const SizedBox(height: 4),
                const Text('SERVER', style: _grey),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [
            _statBox('FITUR', '${d['tools']}', Icons.apps_rounded),
            const SizedBox(width: 8),
            _statBox('FAVORIT', '${d['favorites']}', Icons.star_rounded),
            const SizedBox(width: 8),
            _statBox('RIWAYAT', '${d['history']}', Icons.history),
          ]),
        ]),
      );

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 16, 2, 6),
        child: Row(children: [
          Container(width: 4, height: 16, color: _teal),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 12)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Loader(
        load: () => Api.get('/api/dashboard'),
        build: (c, d, r) {
          final news = d['news'] as List;
          final recent = d['recent'] as List;
          final name = '${Api.me['username']}';
          final id = '${Api.me['id'] ?? ''}';
          final role = '${Api.me['role'] ?? 'user'}';
          final off = Api.fromCache.value;
          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
            _header(c, name),
            const SizedBox(height: 12),
            _quick(c),
            const SizedBox(height: 10),
            _banner(c),
            _welcome(c, name, id, role, off),
            _info(d as Map, off),
            _title('PENGUMUMAN'),
            if (news.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('Belum ada pengumuman', style: TextStyle(color: Colors.grey))),
            for (final n in news)
              _Thick(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${n['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if ('${n['body']}'.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('${n['body']}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                ]),
              ),
            _title('AKTIVITAS TERAKHIR'),
            if (recent.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey))),
            for (final h in recent)
              _Thick(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${h['toolName']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${h['input']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                  ),
                  Text(tgl(h['t']), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
              ),
          ]);
        },
      );
}