import 'package:flutter/material.dart';
import '../../core/utils/colors.dart';
import '../../core/database/db_helper.dart'; // Import the database helper

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // 1. Controller to manage the text input for the hourly rate
  final TextEditingController _rateController = TextEditingController();
  String _currentRate = "93.5"; // Local variable to show in the UI

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  // 2. Load the saved rate from the Database when the screen opens
  Future<void> _loadCurrentSettings() async {
    String? savedRate = await DBHelper().getSetting('hourly_rate');
    if (savedRate != null) {
      setState(() {
        _currentRate = savedRate;
        _rateController.text = savedRate;
      });
    } else {
      _rateController.text = _currentRate;
    }
  }

  // 3. The Function to save the rate to SQLite
  void _saveRate() async {
    if (_rateController.text.isNotEmpty) {
      await DBHelper().updateSetting('hourly_rate', _rateController.text);
      setState(() {
        _currentRate = _rateController.text;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hourly Rate Updated!")),
        );
      }
    }
  }

  // 4. A helper function to show a popup dialog to edit the rate
  void _showEditRateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PrisColors.surface,
        title: const Text("Edit Hourly Rate"),
        content: TextField(
          controller: _rateController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Rate per hour (₹)",
            labelStyle: TextStyle(color: PrisColors.onSurface),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _saveRate();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("Financials"),
          // Updated this tile to trigger the dialog
          _buildSettingTile(
              "Hourly Rate",
              "₹$_currentRate",
              onTap: _showEditRateDialog
          ),

          const SizedBox(height: 32),
          _buildSectionHeader("Vehicle Profile"),
          _buildSettingTile("Tank Capacity", "12 Liters"),
          _buildSettingTile("Reserve Level", "2 Liters"),
          _buildSettingTile("Mileage Baseline", "40 km/L"),

          const SizedBox(height: 32),
          _buildSectionHeader("Data Management"),
          _buildSettingTile("View SQLite Tables", "Raw data access"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: PrisColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text("EXPORT LEDGER TO CSV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(color: PrisColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // Modified Tile to handle tapping
  Widget _buildSettingTile(String title, String trailing, {VoidCallback? onTap}) {
    return Card(
      color: PrisColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailing, style: const TextStyle(color: PrisColors.onSurface)),
            const Icon(Icons.chevron_right, size: 18, color: PrisColors.onSurface),
          ],
        ),
      ),
    );
  }
}