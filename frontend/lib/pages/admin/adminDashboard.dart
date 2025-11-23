import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_config.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _loading = true;
  String? _error;

  int _totalUsers = 0;
  int _totalMeters = 0;
  double _totalKwh = 0;
  int _totalTokenPrice = 0;
  int _lowTokenMeters = 0;

  List<Map<String, dynamic>> _recentUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final uri = Uri.parse(ApiConfig.adminDashboardUrl());
      final res = await http.get(uri);

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          _totalUsers = data['totalUsers'] ?? 0;
          _totalMeters = data['totalMeters'] ?? 0;
          _totalKwh = (data['totalKwh'] as num?)?.toDouble() ?? 0.0;
          _totalTokenPrice = data['totalTokenPrice'] ?? 0;
          _lowTokenMeters = data['lowTokenMeters'] ?? 0;
          _recentUsers =
          List<Map<String, dynamic>>.from(data['recentUsers'] ?? []);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat dashboard admin (${res.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
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
          const Text(
            "Dashboard Admin",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "Pantau seluruh aktivitas pengguna Enerlytix.",
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              _statCard(
                icon: Icons.people,
                title: "Total User",
                value: _totalUsers.toString(),
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _statCard(
                icon: Icons.bolt,
                title: "Total kWh",
                value: "${_totalKwh.toStringAsFixed(1)} kWh",
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _statCard(
                icon: Icons.payments,
                title: "Token Terjual",
                value: "Rp ${_formatRupiah(_totalTokenPrice)}",
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _statCard(
                icon: Icons.warning,
                title: "Token Menipis",
                value: "$_lowTokenMeters Meter",
                color: Colors.red,
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Pengguna Terakhir",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          if (_recentUsers.isEmpty)
            const Text(
              "Belum ada data pengguna.",
              style: TextStyle(color: Colors.black54),
            )
          else
            ..._recentUsers.map(
                  (u) => _userItem(
                u['name'] ?? 'Unknown',
                (u['tokenBalance'] ?? 0).toString(),
                (u['tokenBalance'] ?? 0) >= 10000,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 35, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _userItem(String name, String token, bool safe) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "Token: $token",
                  style: TextStyle(color: safe ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
          Icon(
            safe ? Icons.check_circle : Icons.warning,
            color: safe ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}