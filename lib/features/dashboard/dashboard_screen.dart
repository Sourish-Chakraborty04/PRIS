import 'package:flutter/material.dart';
import '../../core/utils/pris_theme.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome back, Alex!", style: TextStyle(fontSize: 18, color: Colors.white)),
          SizedBox(height: 8),
          Text("TOTAL BALANCE", style: TextStyle(fontSize: 12, color: PrisTheme.onSurface, letterSpacing: 1.5)),
          Text("₹8,450", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: PrisTheme.primary)),

          SizedBox(height: 32),
          Text("PREDICTIVE HEALTH", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PrisTheme.onSurface)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHealthRing("Work", 0.3, "40h", PrisTheme.primary),
              _buildHealthRing("Bike Fuel", 0.65, "65%", Colors.amber),
              _buildHealthRing("Spend", 0.72, "72%", Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRing(String label, double value, String centerText, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80, height: 80,
              child: CircularProgressIndicator(value: value, strokeWidth: 6, color: color, backgroundColor: Colors.white10),
            ),
            Text(centerText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white)),
      ],
    );
  }
}