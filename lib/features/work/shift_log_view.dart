import 'package:flutter/material.dart';
import '../../core/utils/time_calc.dart';
import '../../core/utils/colors.dart';
import '../../core/database/db_helper.dart';
import 'package:intl/intl.dart';
import 'shift_history_view.dart';
import '../settings/settings_view.dart';

class ShiftLogView extends StatefulWidget {
  const ShiftLogView({super.key});

  @override
  State<ShiftLogView> createState() => _ShiftLogViewState();
}

class _ShiftLogViewState extends State<ShiftLogView> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 22, minute: 0);
  double? _hourlyRate;
  List<Map<String, dynamic>> _history = [];
  bool _isVerificationVisible = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // --- NAVIGATION HELPER ---
// 1. Navigation to SETTINGS (for the Hamburger)
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

// 2. Navigation to HISTORY (for the Text and Arrow)
  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ShiftHistoryView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }


// Date picker using the calendar icon
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024), // Set this to whenever you started working
      lastDate: DateTime.now(),   // Prevents logging future shifts
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  // --- DATABASE & LOGIC ---
  bool _shouldShowVerification() {
    int day = DateTime.now().day;
    bool isCorrectDateRange = (day >= 27 && day <= 31) || (day >= 1 && day <= 3);
    return _isVerificationVisible && isCorrectDateRange;
  }

  Future<void> _loadInitialData() async {
    String? rate = await DBHelper().getSetting('hourly_rate');
    List<Map<String, dynamic>> history = await DBHelper().getAllShifts();
    setState(() {
      _hourlyRate = double.tryParse(rate ?? "93.5") ?? 93.5;
      _history = history;
    });
  }

  void _saveShift() async {
    double hours = TimeCalc.calculateShiftHours(startTime, endTime);
    double totalEarnings = hours * (_hourlyRate ?? 0.0);

    Map<String, dynamic> row = {
      // Change DateTime.now() to selectedDate
      'date': DateFormat('EEEE, MMMM dd').format(selectedDate),
      'startTime': startTime.format(context),
      'endTime': endTime.format(context),
      'hours': hours,
      'earnings': totalEarnings,
    };

    await DBHelper().insertShift(row);
    _loadInitialData();

    // Reset to today's date after saving to avoid accidental duplicates
    setState(() {
      selectedDate = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shift Logged Successfully")),
      );
    }
  }

  void _showSalaryCorrectionDialog() {
    final TextEditingController _salaryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Monthly Earnings", style: TextStyle(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: _salaryController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Actual Salary (₹)",
            labelStyle: TextStyle(color: Colors.blueGrey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _navigateToHistory(context), // Points to History
            child: const Text("History", style: TextStyle(color: Colors.blueAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _isVerificationVisible = false);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalWeeklyHours = _history.fold(0, (sum, item) => sum + (item['hours'] as double));
    double totalWeeklyPay = _history.fold(0, (sum, item) => sum + (item['earnings'] as double));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      // Set to false to prevent accidental sidebar swipes
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _navigateToSettings(context), // UI Point 1
        ),
        title: const Text("Work History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_shouldShowVerification()) ...[
              _buildVerificationCard(),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shift Logging", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                TextButton(
                  onPressed: () => _navigateToHistory(context), // UI Point 2
                  child: const Text("History", style: TextStyle(color: Colors.blueAccent)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLoggingConsole(),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildSummaryCard("HOURS THIS WEEK", totalWeeklyHours.toStringAsFixed(1), "+ 2.4h", true)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard("ESTIMATED PAY", "₹${totalWeeklyPay.toStringAsFixed(0)}", "Current period", false)),
              ],
            ),
            const SizedBox(height: 32),
            const Text("Last Shift", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            if (_history.isNotEmpty) _buildLastShiftCard(_history.first) else const Text("No shifts yet", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.2))),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    "Earnings Verification\nIs ₹${NumberFormat('#,##,###').format(13000)} accurate for your ${DateFormat('MMMM').format(DateTime.now())} earnings?",
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _showSalaryCorrectionDialog, child: const Text("No - Edit", style: TextStyle(color: Colors.blueAccent))),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => setState(() => _isVerificationVisible = false),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoggingConsole() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Wrap the text in an InkWell so tapping the date also opens the picker
              InkWell(
                onTap: () => _selectDate(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SELECTED SHIFT DATE", // Changed from "TODAY'S" since it's now dynamic
                      style: TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('EEEE, MMM dd').format(selectedDate),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // The Icon also triggers the picker
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined, color: Colors.blueAccent, size: 20),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTimeInput("Start Time", startTime, true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeInput("End Time", endTime, false)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveShift,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text("Log Shift Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTimeInput(String label, TimeOfDay time, bool isStart) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) setState(() => isStart ? startTime = picked : endTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 10)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time.format(context).split(' ')[0], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(time.period == DayPeriod.am ? "AM" : "PM", style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, String subtext, bool isTrend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isTrend) const Icon(Icons.trending_up, color: Colors.greenAccent, size: 14),
              Text(subtext, style: TextStyle(color: isTrend ? Colors.greenAccent : Colors.blueGrey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLastShiftCard(Map<String, dynamic> shift) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(shift['date'].toString().toUpperCase(), style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Duration", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                  Text("${shift['hours']} hrs", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 20),
              Container(width: 1, height: 30, color: Colors.white10),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Earnings", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                  Text("₹${shift['earnings'].toStringAsFixed(0)}", style: const TextStyle(color: Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.blueGrey),
                onPressed: () => _navigateToHistory(context), // UI Point 3
              ),
            ],
          )
        ],
      ),
    );
  }
}