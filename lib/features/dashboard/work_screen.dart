import 'package:flutter/material.dart';
import '../../core/utils/pris_theme.dart';

class WorkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Earnings Verification Card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PrisTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PrisTheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: PrisTheme.primary),
                SizedBox(width: 12),
                Expanded(child: Text("Is ₹13,000 accurate for May?", style: TextStyle(fontSize: 14))),
                TextButton(onPressed: () {}, child: Text("YES", style: TextStyle(color: PrisTheme.primary))),
              ],
            ),
          ),

          SizedBox(height: 24),
          // Shift Logger
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTimeInput("Start Time", "12:00", "PM"),
                  Divider(height: 32, color: Colors.white10),
                  _buildTimeInput("End Time", "10:00", "PM"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(String label, String time, String period) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: PrisTheme.onSurface, fontSize: 12)),
          Text(time, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: PrisTheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
          child: Text(period, style: TextStyle(color: PrisTheme.primary, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}