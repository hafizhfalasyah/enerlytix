import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/api_config.dart';

class UserMonitoringPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const UserMonitoringPage({super.key, this.user});

  @override
  State<UserMonitoringPage> createState() => _UserMonitoringPageState();
}

class _UserMonitoringPageState extends State<UserMonitoringPage> {
  bool _loading = true;
  String? _error;

  int token = 0;
  double kwhToday = 0;
  int wattNow = 0;
  int daya = 0;
  List<double> history = [];

  @override
  void initState() {
    super.initState();
    _fetchMonitoring();
  }

  Future<void> _fetchMonitoring() async {
    try {
      final userId = widget.user?['id'];
      if (userId == null) {
        setState(() {
          _error = 'User ID tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final uri = Uri.parse(ApiConfig.userMonitoringUrl(userId));
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final meter = data['meter'];
        final List<dynamic> hist = data['history'] ?? [];

        setState(() {
          token = meter['tokenBalance'] as int;
          daya = meter['powerLimitVa'] as int;
          wattNow = meter['currentWatt'] as int;
          kwhToday = (data['kwhToday'] as num).toDouble();
          history = hist
              .map<double>((e) => (e['kwhUsed'] as num).toDouble())
              .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat monitoring (${res.statusCode})';
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

    final bool lowToken = token < 10000;
    final bool highKwh = kwhToday > 4.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monitoring Listrik Anda",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "Pantau penggunaan listrik secara realtime.",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 25),

          _mainCard(
            icon: Icons.payments,
            title: "Token Anda",
            value: "Rp $token",
            color: Colors.blue,
            progress: (token / 100000).clamp(0.0, 1.0),
            status: lowToken ? "Token Menipis" : "Aman",
            statusColor: lowToken ? Colors.red : Colors.green,
          ),

          const SizedBox(height: 18),

          _mainCard(
            icon: Icons.bolt,
            title: "Pemakaian Hari Ini",
            value: "${kwhToday.toStringAsFixed(1)} kWh",
            color: Colors.orange,
            progress: (kwhToday / 10).clamp(0.0, 1.0),
            status: highKwh ? "Pemakaian Tinggi" : "Normal",
            statusColor: highKwh ? Colors.orange : Colors.green,
          ),

          const SizedBox(height: 18),

          _wattCard(),

          const SizedBox(height: 25),

          const Text(
            "Riwayat Pemakaian",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),
          ..._buildHistory(),
        ],
      ),
    );
  }

  Widget _mainCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double progress,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            minHeight: 8,
            borderRadius: BorderRadius.circular(20),
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _wattCard() {
    final double wattPercentage =
    daya == 0 ? 0 : (wattNow / daya).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Beban Saat Ini",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.flash_on, size: 32, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$wattNow Watt",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: wattPercentage,
            backgroundColor: Colors.grey.shade300,
            minHeight: 8,
            color: wattPercentage > 0.8 ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 8),
          Text(
            wattPercentage > 0.8 ? "⚠ Beban Tinggi" : "Aman",
            style: TextStyle(
              color: wattPercentage > 0.8 ? Colors.red : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHistory() {
    final labels = [
      "Hari ini",
      "Kemarin",
      "2 hari lalu",
      "3 hari lalu",
      "4 hari lalu",
    ];

    return List.generate(history.length, (i) {
      final label = i < labels.length ? labels[i] : "Hari -${i}";

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              "${history[i].toStringAsFixed(1)} kWh",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }
}