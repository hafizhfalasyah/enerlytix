import 'package:flutter/material.dart';
import 'adminDashboard.dart';
import 'adminToken.dart';
import 'adminMonitoring.dart';

class HomeAdminPage extends StatefulWidget {
  final String? token;
  final Map<String, dynamic>? user;

  const HomeAdminPage({super.key, this.token, this.user});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      AdminDashboardPage(),
      AdminTokenPage(),
      AdminMonitoringPage(),
    ];
  }

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user?["name"] ?? "Admin";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.deepOrange.shade100,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dashboard Admin",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Halo, $name 👋",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_selectedIndex],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            iconSize: 26,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_customize_rounded),
                label: "Dashboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bolt_rounded),
                label: "Token",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.monitor_heart_rounded),
                label: "Monitoring",
              ),
            ],
          ),
        ),
      ),
    );
  }
}