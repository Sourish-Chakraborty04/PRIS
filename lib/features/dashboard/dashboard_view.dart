import 'package:flutter/material.dart';
import '../../core/utils/colors.dart';
import '../settings/settings_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrisColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('PRIS', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("TOTAL BALANCE",
                style: TextStyle(color: PrisColors.onSurface, letterSpacing: 1.2, fontSize: 12)),
            const SizedBox(height: 8),
            const Text("₹ 8,450.00",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: PrisColors.primary)),
            const SizedBox(height: 32),
            const Text("PREDICTIVE HEALTH",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRing("Work", 0.30, "40h", PrisColors.primary),
                _buildRing("Fuel", 0.65, "65%", PrisColors.gaugeYellow),
                _buildRing("Spend", 0.72, "72%", PrisColors.gaugeRed),
              ],
            ),
          ],
        ),
      ),
    );
  } // <--- This closes the Build Method

  // This method is now safely INSIDE the DashboardView class
  Widget _buildRing(String label, double progress, String value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80, height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                color: color,
                backgroundColor: Colors.white10,
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: PrisColors.onSurface, fontSize: 12)),
      ],
    );
  }
} // <--- This closes the DashboardView Class