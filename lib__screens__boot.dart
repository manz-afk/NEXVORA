import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/core.dart';
import 'auth_page.dart';
import 'home.dart';

class Boot extends StatefulWidget {
  const Boot({super.key});
  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  String status = 'Mencari server...';
  bool manual = false;
  List<String> gist = [];
  final urlC = TextEditingController();

  @override
  void initState() {
    super.initState();
    go();
  }

  Future<void> go() async {
    setState(() { manual = false; status = 'Mencari server...'; });
    await Api.load();
    bool ok = Api.base.isNotEmpty && await Api.ping(Api.base, const Duration(seconds: 4));
    if (!ok && await Api.ping(Api.defaultBase, const Duration(seconds: 4))) { await Api.setBase(Api.defaultBase); ok = true; }
    if (!ok) {
      final g = await Api.fromGist();
      if (g != null) { await Api.setBase(g); ok = true; }
    }
    if (!ok) {
      final f = await Api.discover();
      if (f != null) { await Api.setBase(f); ok = true; }
    }
    if (!ok) {
      final list = await Api.gistList();
      if (mounted) {
        setState(() {
          gist = list;
          manual = true;
          status = list.isEmpty
              ? 'Server tidak ketemu otomatis. Masukkan alamat server.'
              : 'Server tidak ketemu otomatis. Pilih alamat terbaru di bawah, atau masukkan alamat sendiri.';
        });
      }
      return;
    }
    await next();
  }

  Future<void> next() async {
    if (Api.token.isNotEmpty) {
      try {
        Api.me = (await Api.get('/api/me'))['user'];
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
        return;
      } catch (_) { await Api.setToken(''); }
    }
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
  }

  /// Pakai satu alamat dari Gist: cek dulu, kalau bisa langsung masuk.
  Future<void> useAddr(String u) async {
    setState(() => status = 'Mengecek $u ...');
    if (await Api.ping(u, const Duration(seconds: 5))) {
      await Api.setBase(u);
      await next();
    } else {
      setState(() => status = 'Alamat $u tidak merespon. Coba alamat lain atau tunggu beberapa menit.');
    }
  }

  Future<void> useManual() async {
    var u = urlC.text.trim();
    if (u.isEmpty) return;
    final hasPort = RegExp(r':\d+(/|$)').hasMatch(u.replaceAll(RegExp(r'^https?://'), ''));
    final isHttps = u.startsWith('https://');
    if (!hasPort && !isHttps) {
      setState(() => status = 'Mencari port di $u ...');
      final f = await Api.discoverHost(u);
      if (f != null) { await Api.setBase(f); await next(); return; }
      setState(() => status = 'Tidak ada server di $u. Cek apakah server panel sudah Start.');
      return;
    }
    if (!u.startsWith('http')) u = 'http://$u';
    setState(() => status = 'Mengecek...');
    if (await Api.ping(u)) { await Api.setBase(u); await next(); }
    else { setState(() => status = 'Server tidak merespon di $u'); }
  }

  Widget gistCard(String addr) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: SelectableText(addr, style: const TextStyle(fontFamily: 'monospace'))),
            IconButton(
              tooltip: 'Salin',
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: addr));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat disalin')));
              },
            ),
            FilledButton(onPressed: () => useAddr(addr), child: const Text('Pakai')),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset('assets/logo.png', width: 96, height: 96)),
              const SizedBox(height: 12),
              const Text('NEXVORA', style: TextStyle(fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.w300)),
              const Text('Akses Server', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Text(status, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (!manual) const CircularProgressIndicator(),
              if (manual) ...[
                if (gist.isNotEmpty) ...[
                  const Align(alignment: Alignment.centerLeft, child: Text('Alamat terbaru dari admin:', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  for (final a in gist) ...[gistCard(a), const SizedBox(height: 8)],
                  const SizedBox(height: 12),
                ],
                const Align(alignment: Alignment.centerLeft, child: Text('Masukan nomornya saja tanpa HTTP/HTTPS 🤖', style: TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                TextField(controller: urlC, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'IP server (port boleh dikosongkan)', hintText: 'contoh: 38.253.224.75:3205', helperText: 'Masukan nomornya saja tanpa HTTP/HTTPS 🤖', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  FilledButton(onPressed: useManual, child: const Text('Hubungkan')),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: go, child: const Text('Cari ulang')),
                ]),
              ],
            ]),
          ),
        ),
      );
}