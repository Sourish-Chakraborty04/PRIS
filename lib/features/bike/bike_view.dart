import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import '../settings/settings_view.dart';
class BikeView extends StatefulWidget {
  const BikeView({super.key});

  @override
  State<BikeView> createState() => _BikeViewState();
}

class _BikeViewState extends State<BikeView> {
  // State Variables
  double _fuelLevelPercent = 0.0;
  double _tankCapacity = 9.1; // Dynamic Liter Capacity
  double _currentOdo = 00000.0;
  String _lastSynced = "Just now";
  final double _maxRange = 500.5;

  void _updateFuel(double newValue) {
    setState(() {
      _fuelLevelPercent = newValue;
      _lastSynced = DateFormat('jm').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      drawerEnableOpenDragGesture: false,
      // Drawer acts as your Settings/Menu page
      // drawer: Drawer(
      //   backgroundColor: const Color(0xFF0F172A),
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       const DrawerHeader(
      //         decoration: BoxDecoration(color: Color(0xFF1E293B)),
      //         child: Text("Settings", style: TextStyle(color: Colors.white, fontSize: 24)),
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.settings, color: Colors.white),
      //         title: const Text("Preferences", style: TextStyle(color: Colors.white)),
      //         onTap: () => Navigator.pop(context),
      //       ),
      //     ],
      //   ),
      // ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const SettingsView(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      // This defines the "scrolling" direction and smoothness
                      const begin = Offset(-1.0, 0.0); // Starts from the Left (like the drawer)
                      const end = Offset.zero;
                      const curve = Curves.easeInOutCubic; // Smooth "running" feel

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 500), // Adjust speed here
                  ),
                );
              },
          ),
          title: const Text("Bike",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- NEON GAUGE WITH DYNAMIC TICKS ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                SizedBox(
                height: 290, // Increased height to give the gauge room to breathe
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: _tankCapacity, // Dynamic max based on liters
                      interval: 1,
                      showLabels: true,
                      showTicks: true,
                      startAngle: 180,
                      endAngle: 0,
                      radiusFactor: 1.0, // Scale up to fill the width
                      canScaleToFit: true,
                      labelOffset: 25, // Moves numbers further inward to avoid congestion
                      axisLabelStyle: const GaugeTextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12, // Slightly larger font for readability
                          fontWeight: FontWeight.w500
                      ),
                      majorTickStyle: const MajorTickStyle(
                          length: 12,
                          thickness: 2,
                          color: Colors.white24
                      ),
                      axisLineStyle: const AxisLineStyle(
                        thickness: 0.20, // Thicker arc for a bolder look
                        thicknessUnit: GaugeSizeUnit.factor,
                        gradient: SweepGradient(
                          colors: <Color>[
                            Color(0xFFFF0000), // Neon Red
                            Color(0xFFFFD700), // Bright Gold
                            Color(0xFF00FF00), // Neon Green
                          ],
                          stops: <double>[0.1, 0.4, 0.8],
                        ),
                      ),
                      pointers: <GaugePointer>[
                        NeedlePointer(
                          value: (_fuelLevelPercent / 100) * _tankCapacity,
                          needleLength: 0.8, // Longer needle to match the bigger gauge
                          enableAnimation: true,
                          animationType: AnimationType.easeOutBack,
                          animationDuration: 1500,
                          knobStyle: const KnobStyle(
                              knobRadius: 0.07,
                              color: Colors.blueAccent
                          ),
                          needleColor: Colors.blueAccent,
                          needleStartWidth: 1,
                          needleEndWidth: 6,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_fuelLevelPercent.toInt()}%',
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                            ],
                          ),
                          angle: 90,
                          positionFactor: 0.35, // Adjusted position for the larger scale
                        )
                      ],
                    )
                  ],
                ),
              ),
                  Text("${(_maxRange * (_fuelLevelPercent / 100)).toInt()} km",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("ESTIMATED RANGE", style: TextStyle(color: Colors.blueGrey, fontSize: 10, letterSpacing: 1.5)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- ACTION BUTTONS ---
            Row(
              children: [
                Expanded(child: _buildActionButton(Icons.edit_note, "Update\nOdometer", () async {
                  final double? result = await showModalBottomSheet<double>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => OdometerSheet(lastReading: _currentOdo),
                  );
                  if (result != null) {
                    setState(() {
                      _currentOdo = result;
                      _lastSynced = "Just now";
                    });
                  }
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildActionButton(Icons.local_gas_station, "Full Tank/\nRefuel", () {
                  _updateFuel(100.0);
                }, isPrimary: true)),
              ],
            ),

            const SizedBox(height: 12),

            // --- UPDATE BIKE DETAILS BUTTON ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: const [
                  Icon(Icons.settings, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Icon(Icons.directions_bike, color: Colors.white70, size: 18),
                  SizedBox(width: 12),
                  Text("Update Bike Details", style: TextStyle(color: Colors.white, fontSize: 14)),
                  Spacer(),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white70),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- SMART INSIGHTS BANNER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blueAccent, size: 28),
                  const SizedBox(height: 8),
                  const Text("Smart Insights", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                  const SizedBox(height: 12),
                  const Text("Predicted Refuel Date:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Thursday", style: TextStyle(color: Colors.blueAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Based on your recent commuting patterns", style: TextStyle(color: Colors.blueGrey, fontSize: 10)),
                ],
              ),
            ),

            const SizedBox(height: 1),

            // --- STATS SECTION ---
            _buildStatRow("Last Synced", _lastSynced),
            _buildStatRow("Current Odometer", "${_currentOdo.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km"),
            // _buildStatRow("Service Due", "In 542 km", valueColor: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.blueAccent : const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color valueColor = Colors.white}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
              Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(color: Colors.white10, height: 1),
      ],
    );
  }
}

// --- ODOMETER BOTTOM SHEET ---
class OdometerSheet extends StatefulWidget {
  final double lastReading;
  const OdometerSheet({super.key, required this.lastReading});

  @override
  State<OdometerSheet> createState() => _OdometerSheetState();
}

class _OdometerSheetState extends State<OdometerSheet> {
  String _inputText = "";

  void _onKeyPress(String value) {
    setState(() {
      if (value == "back") {
        if (_inputText.isNotEmpty) _inputText = _inputText.substring(0, _inputText.length - 1);
      } else if (_inputText.length < 7) {
        _inputText += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double newReading = _inputText.isEmpty ? 0 : double.parse(_inputText) / 10;
    double travel = newReading > widget.lastReading ? newReading - widget.lastReading : 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text("Update Odometer", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildOdometerRow(_inputText.padLeft(7, '0')),
          const SizedBox(height: 30),
          _buildKeypad(),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(context, newReading),
            child: const Text("Update Reading", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          Text("Travel: +${travel.toStringAsFixed(1)} KM", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOdometerRow(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 6; i++) _digitBox(text[i], false),
        const Text(" . ", style: TextStyle(color: Colors.blueAccent, fontSize: 30, fontWeight: FontWeight.bold)),
        _digitBox(text[6], true),
      ],
    );
  }

  Widget _digitBox(String val, bool isDecimal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 40, height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDecimal ? Colors.blueAccent : Colors.white10, width: 1.5),
      ),
      child: Center(child: Text(val, style: TextStyle(color: isDecimal ? Colors.white : Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildKeypad() {
    var keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "back"];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.8, mainAxisSpacing: 12, crossAxisSpacing: 12),
      itemCount: keys.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => _onKeyPress(keys[i] == "." ? "" : keys[i]),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: keys[i] == "back"
                ? const Icon(Icons.backspace_outlined, color: Colors.blueAccent)
                : Text(keys[i], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}