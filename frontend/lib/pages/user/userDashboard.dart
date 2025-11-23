import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_config.dart';

class UserDashboardPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const UserDashboardPage({super.key, this.user});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  bool _loading = true;
  String? _error;

  late String _name;
  int _daya = 0;
  double _kwhToday = 0;
  int _tokenBalance = 0;

  @override
  void initState() {
    super.initState();
    _name = widget.user?['name'] ?? 'Pengguna';
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final userId = widget.user?['id'];
      if (userId == null) {
        setState(() {
          _error = 'User ID tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final uri = Uri.parse(ApiConfig.userDashboardUrl(userId));
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final meter = data['meter'];
        setState(() {
          _name = data['user']['name'] ?? _name;
          _daya = meter['powerLimitVa'] as int;
          _kwhToday = (meter['kwhToday'] as num).toDouble();
          _tokenBalance = meter['tokenBalance'] as int;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat dashboard (${res.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  String _formatRupiah(int value) {
    final s = value.toString();
    return s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => "${m[1]}.",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Halo, $_name 👋",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "Selamat datang kembali di Enerlytix!",
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),

          const SizedBox(height: 25),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.electric_bolt, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                const Text(
                  "Saldo Token",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  "Rp ${_formatRupiah(_tokenBalance)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: _statusCard(
                  title: "Status Daya",
                  value: "$_daya VA",
                  icon: Icons.bolt,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statusCard(
                  title: "Pemakaian Hari Ini",
                  value: "${_kwhToday.toStringAsFixed(1)} kWh",
                  icon: Icons.show_chart,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.info, color: Colors.blue, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Gunakan daya secara efisien untuk menghemat pengeluaran listrik harian.",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}