import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_config.dart';

class AdminMonitoringPage extends StatefulWidget {
  const AdminMonitoringPage({super.key});

  @override
  State<AdminMonitoringPage> createState() => _AdminMonitoringPageState();
}

class _AdminMonitoringPageState extends State<AdminMonitoringPage> {
  bool loading = true;
  String? error;

  double totalKwhToday = 0;
  int activeUsers = 0;

  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchMonitoring();
  }

  Future<void> _fetchMonitoring() async {
    try {
      final uri = Uri.parse(ApiConfig.adminMonitoringUrl());
      final res = await http.get(uri);

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          totalKwhToday = (data['totalKwhToday'] as num?)?.toDouble() ?? 0.0;
          activeUsers = data['activeUsers'] ?? 0;
          users = List<Map<String, dynamic>>.from(data['list'] ?? []);
          loading = false;
        });
      } else {
        setState(() {
          error = 'Gagal memuat monitoring admin (${res.statusCode})';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(error!),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monitoring Penggunaan",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Pantau aktivitas konsumsi listrik seluruh pengguna.",
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              _statCard(
                title: "Total KWH Hari Ini",
                value: "${totalKwhToday.toStringAsFixed(1)} kWh",
                icon: Icons.bolt,
                color: Colors.orange,
              ),
              const SizedBox(width: 15),
              _statCard(
                title: "User Aktif",
                value: "$activeUsers",
                icon: Icons.people,
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            "Daftar Pemakaian User",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          ...users.map((u) => _userCard(u)).toList(),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
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

  Widget _userCard(Map<String, dynamic> user) {
    final name = (user['name'] ?? '') as String;
    final token = (user['token'] ?? 0) as int;
    final kwh = (user['kwh'] as num?)?.toDouble() ?? 0.0;
    final watt = (user['watt'] as num?)?.toDouble() ?? 0.0;

    final bool lowToken = token < 5000;
    final bool highUsage = kwh > 3.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.deepOrange,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _badge(
                          text: "Token: $token",
                          color: lowToken ? Colors.red : Colors.green,
                        ),
                        _badge(
                          text: "KWH: ${kwh.toStringAsFixed(1)}",
                          color: highUsage ? Colors.orange : Colors.blue,
                        ),
                        _badge(
                          text: "Watt: ${watt.toStringAsFixed(0)}",
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(
                lowToken ? Icons.warning_amber_rounded : Icons.check_circle,
                size: 28,
                color: lowToken ? Colors.red : Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            highUsage ? "⚡ Pemakaian Tinggi" : "• Pemakaian Normal",
            style: TextStyle(
              color: highUsage ? Colors.orange : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}