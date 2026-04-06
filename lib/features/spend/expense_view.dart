import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../settings/settings_view.dart';
import '../../core/database/db_helper.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../assets/data/categories.json';

class ExpenseView extends StatefulWidget {
  const ExpenseView({super.key});

  @override
  State<ExpenseView> createState() => _SpendViewState();
}

class _SpendViewState extends State<ExpenseView> {

  //DATABASE CONNECTION
  @override
  void initState() {
    super.initState();
    _refreshExpenses(); // Fetch data immediately
  }

  Future<void> _refreshExpenses() async {
    final data = await DBHelper().getAllExpenses();
    setState(() {
      _allTransactions = data;
    });
  }

  Future<void> _refreshData() async {
    final catData = await DBHelper().getAllCategories();

    setState(() {
      _categories = catData.map((item) => {
        "name": item['name'],
        "emoji": item['emoji'] ?? "📦", // Pulls the string from DB
        "keywords": item['keywords'],
        "color": Color(item['color_value'] ?? 0xFF64748B), // Fallback to Slate if null
      }).toList();
    });
  }

  // 1.STATE VARIABLES
  bool _isMenuOpen = false;
  String _calcDisplay = "0";
  String _activeFilter = "All";
  DateTime _selectedEntryDate = DateTime.now();

  // 2. DATA LISTS (Temporary until Step 4)
  List<Map<String, dynamic>> _categories = [];

  List<Map<String, dynamic>> _allTransactions = []; // Starts empty, fills from DB

  // Helper for the top filter row
  List<Map<String, dynamic>> get _feedCategories => [
    {"name": "All", "icon": Icons.layers, "color": Colors.white},
    ..._categories,
  ];

  // 3. CORE LOGIC METHODS
  void _toggleMenu() => setState(() => _isMenuOpen = !_isMenuOpen);

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const SettingsView(),
        transitionsBuilder: (context, anim, secAnim, child) {
          var tween = Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOutCubic));
          return SlideTransition(position: anim.drive(tween), child: child);
        },
      ),
    );
  }

  // Transaction deletion (Long-press trigger)
  void _deleteTransaction(int id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Delete Log?", style: TextStyle(color: Colors.white)),
        content: Text("Remove '$title'?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
          onPressed: () async {
          // Add a delete method to your DBHelper if missing, or use this raw:
          final db = await DBHelper().database;
          await db.delete('expenses', where: 'id = ?', whereArgs: [id]);

          _refreshExpenses(); // Refresh the list
          Navigator.pop(context);
          },
          child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Step 1: Show the list of categories to pick one for deletion
  void _showDeleteCategoryDialog() {
    String? selectedCategory;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("Delete Category", style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return RadioListTile<String>(
                  title: Text(cat['name'], style: const TextStyle(color: Colors.white)),
                  value: cat['name'],
                  groupValue: selectedCategory,
                  activeColor: Colors.redAccent,
                  onChanged: (val) => setDialogState(() => selectedCategory = val),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: selectedCategory == null ? null : () => _confirmDelete(selectedCategory!),
              child: Text("DELETE", style: TextStyle(
                  color: selectedCategory == null ? Colors.white10 : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  shadows: selectedCategory == null ? [] : [const Shadow(color: Colors.redAccent, blurRadius: 10)]
              )),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: The actual "Confirm Delete" block you were looking for
  void _confirmDelete(String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("Confirm", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete '$categoryName'?",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _categories.removeWhere((cat) => cat['name'] == categoryName);
                if (_activeFilter == categoryName) _activeFilter = "All";
              });
              Navigator.pop(context); // Close confirm
              Navigator.pop(context); // Close selection list
            },
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }

  // Helper to get icons automatically
  IconData _getIconForCategory(String name) {
    String lower = name.toLowerCase();
    if (lower.contains('food')) return Icons.restaurant;
    if (lower.contains('fuel')) return Icons.local_gas_station;
    if (lower.contains('chai')) return Icons.coffee;
    if (lower.contains('wifi')) return Icons.wifi;
    return Icons.category_rounded;
  }

  // The Category "Boom Buttons" inside the sheet
  Widget _buildBoomButton(
      String label,
      String emoji,
      Color color,
      StateSetter modalSetState, // Used to update the sheet UI if needed
      String titleInput
      ) {
    return GestureDetector(
      onTap: () async {
        // 1. Validation
        if (_calcDisplay == "0" || _calcDisplay.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enter an amount first!")),
          );
          return;
        }

        // 2. Prepare Data
        String finalTitle = titleInput.trim().isEmpty ? label : titleInput.trim();

        // 3. Save to DB
        await DBHelper().insertExpense({
          'category': label,
          'title': finalTitle,
          'amount': double.parse(_calcDisplay),
          'date': DateFormat('dd MMM yyyy').format(_selectedEntryDate),
        });

        // 4. UI Feedback & Cleanup
        await _refreshExpenses(); // Refresh the feed in the background

        Navigator.pop(context); // This closes the Manual Entry sheet immediately

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Saved ₹$_calcDisplay for $finalTitle"),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)), // The Emoji
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // The Colorful Keypad Grid
  Widget _buildColorfulKeypad(StateSetter modalSetState) {
    final List<Map<String, dynamic>> keys = [
      {"val": "1", "color": Colors.white}, {"val": "2", "color": Colors.white}, {"val": "3", "color": Colors.white},
      {"val": "4", "color": Colors.white}, {"val": "5", "color": Colors.white}, {"val": "6", "color": Colors.white},
      {"val": "7", "color": Colors.white}, {"val": "8", "color": Colors.white}, {"val": "9", "color": Colors.white},
      {"val": "C", "color": Colors.redAccent}, {"val": "0", "color": Colors.white}, {"val": "⌫", "color": Colors.orangeAccent},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 1.6, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) => InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          modalSetState(() {
            String val = keys[index]["val"];
            if (val == "C") _calcDisplay = "0";
            else if (val == "⌫") {
              _calcDisplay = _calcDisplay.length > 1 ? _calcDisplay.substring(0, _calcDisplay.length - 1) : "0";
            } else {
              _calcDisplay = _calcDisplay == "0" ? val : _calcDisplay + val;
            }
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
          child: Text(keys[index]["val"], style: TextStyle(color: keys[index]["color"], fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _pickEntryDate(StateSetter modalSetState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEntryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
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
    if (picked != null) {
      modalSetState(() {
        _selectedEntryDate = picked;
      });
    }
  }

  void _addNewCategory(StateSetter refreshSource) {
    TextEditingController _catController = TextEditingController();

    showDialog(
      context: context, // Use the global context
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("New Category", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _catController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Category name...",
            hintStyle: TextStyle(color: Colors.white24),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              String name = _catController.text.trim();
              if (name.isNotEmpty) {
                // 1. Save to DB
                await DBHelper().insertCategory({
                  'name': name,
                  'emoji': "📦", // Default emoji for new manual ones
                  'macro': "Misc",
                  'keywords': name.toLowerCase(),
                  'color_value': Colors.blueGrey.value,
                });

                // 2. Refresh the Main Screen State
                await _refreshData();

                // 3. Force the triggering UI (Bottom Sheet or Dialog) to rebuild
                refreshSource(() {});

                Navigator.pop(dialogContext);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showManualEntry() {
    if (_isMenuOpen) _toggleMenu();

    // Controller to capture the title/note
    final TextEditingController _titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          // Adjusted height to ensure keypad doesn't overlap
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))
              ),
              const SizedBox(height: 20),

              // Amount Display
              Text(
                  "₹ $_calcDisplay",
                  style: const TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.bold)
              ),

              const SizedBox(height: 20),
              const Spacer(),

              // --- CATEGORY SELECTION ROW ---
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      onPressed: () => _addNewCategory(setModalState),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 1.5),
                        ),
                        child: const Icon(Icons.add, color: Colors.blueAccent),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        // IMPORTANT: Changed cat['icon'] to cat['emoji'] for your new JSON DB
                        children: _categories.map((cat) => _buildBoomButton(
                            cat['name'],
                            cat['emoji'], // Updated to use the emoji string
                            cat['color'],
                            setModalState,
                            _titleController.text // Passing the title to save
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Keypad
              _buildColorfulKeypad(setModalState),
            ],
          ),
        ),
      ),
    ).then((_) {
      setState(() {
        _calcDisplay = "0";
      });
    });
  }

  // 4. MAIN BUILDER
  @override
  Widget build(BuildContext context) {
    // 1. Format the search key for when a specific category is selected
    String filterDateStr = DateFormat('dd MMM yyyy').format(_selectedEntryDate);

    // 2. SMART FILTER:
    // If "All", show everything. If a category is picked, show only that category for that date.
    var filteredList = _allTransactions.where((t) {
      if (_activeFilter == "All") {
        return true; // Don't filter at all, show every transaction in the DB
      } else {
        // Filter by BOTH Category and the selected Date
        bool matchesDate = t['date'] == filterDateStr;
        bool matchesCategory = t['category'] == _activeFilter;
        return matchesDate && matchesCategory;
      }
    }).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _navigateToSettings(context)
        ),
        title: const Text("Expenses", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.calendar_month, color: Colors.white),
              onPressed: _showFilterDatePicker // This is now linked!
          ),
          _buildThreeDotMenu(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _feedCategories.map((c) => _buildCategoryChip(c)).toList(),
              ),
            ),
            _buildDateIndicator(),

            const SizedBox(height: 20),
            const Text("Transaction Feed", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // The List of Transactions
            if (filteredList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text("No entries for this day", style: TextStyle(color: Colors.white24)),
                ),
              )
            else
              ...filteredList.map((t) => _buildExpenseTile(
                t['category']?.toString() ?? "Misc",
                t['date']?.toString() ?? "No Date",
                "₹${t['amount'] ?? '0'}",
                t['category']?.toString() ?? "Chai",
                t['id'] ?? 0,
              )).toList(),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 250,
        width: 200,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            _buildFabOption(
              label: "Manual Entry",
              icon: Icons.edit_note,
              bottomOffset: _isMenuOpen ? 140 : 0,
              delay: 100,
              onTap: () => _showManualEntry(),
            ),
            _buildFabOption(
              label: "Screenshot",
              icon: Icons.camera_alt,
              bottomOffset: _isMenuOpen ? 80 : 0,
              delay: 0,
              onTap: () {},
            ),
            GestureDetector(
              onTap: _toggleMenu,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 300),
                turns: _isMenuOpen ? 0.125 : 0,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. UI COMPONENT HELPERS
  Widget _buildCategoryChip(Map<String, dynamic> cat) {
    bool isSelected = _activeFilter == cat['name'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = cat['name'];
        });
        _refreshExpenses();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (cat['color'] as Color).withOpacity(0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? cat['color'] : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(cat['icon'], color: isSelected ? cat['color'] : Colors.blueGrey, size: 18),
            const SizedBox(width: 8),
            Text(cat['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateIndicator() {
    bool isToday = DateFormat('ddMM').format(_selectedEntryDate) == DateFormat('ddMM').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.event_note, color: Colors.blueGrey.withOpacity(0.6), size: 16),
          const SizedBox(width: 8),
          Text(
            "Showing: ${DateFormat('dd MMM yyyy').format(_selectedEntryDate)}",
            style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          if (!isToday)
            GestureDetector(
              onTap: () => setState(() => _selectedEntryDate = DateTime.now()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Reset to Today",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(String title, String date, String amount, String categoryName, int id) {
    // Use 'categoryName' (the argument) to find the right icon and color
    var cat = _categories.firstWhere(
            (c) => c['name'] == categoryName,
        orElse: () => {"icon": Icons.receipt, "color": Colors.blueGrey}
    );

    return GestureDetector(
      // Use 'id' and 'title' from the arguments
      onLongPress: () => _deleteTransaction(id, title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: (cat['color'] as Color).withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: (cat['color'] as Color).withOpacity(0.1),
                child: Icon(cat['icon'], color: cat['color'], size: 20)
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(date, style: const TextStyle(color: Colors.blueGrey, fontSize: 11))
                    ]
                )
            ),
            Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeDotMenu() {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'add') {
          _addNewCategory(setState);
        } else if (val == 'manage') {
          _showDeleteCategoryDialog();
        }
        // Add export logic here later if needed
      },
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: const Color(0xFF1E293B),
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: 'add',
            child: Text("Add Category", style: TextStyle(color: Colors.white))
        ),
        const PopupMenuItem(
            value: 'manage',
            child: Text("Manage Categories", style: TextStyle(color: Colors.white))
        ),
        const PopupMenuItem(
            value: 'export',
            child: Text("Export Report", style: TextStyle(color: Colors.white))
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required String label,
    required IconData icon,
    required double bottomOffset,
    required int delay,
    required VoidCallback onTap,
  }) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 250 + delay),
      curve: Curves.easeOutBack,
      bottom: bottomOffset,
      right: 5,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isMenuOpen ? 1.0 : 0.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 15),
            FloatingActionButton.small(
              onPressed: _isMenuOpen ? onTap : null,
              backgroundColor: Colors.blueAccent,
              elevation: 0,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _showFilterDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEntryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              surface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEntryDate = picked;
      });
    }
  }

  // Category wise color picker
  int _getMacroColor(String macro) {
    switch (macro) {
      case "Food":
        return Colors.orangeAccent.value;
      case "Drink":
        return Colors.cyanAccent.value;
      case "Personal Care":
        return Colors.pinkAccent.value;
      case "Household":
        return Colors.greenAccent.value;
      case "Transport":
        return Colors.blueAccent.value;
      case "Bills":
        return Colors.redAccent.value;
      case "Shopping":
        return Colors.amberAccent.value;
      case "Health":
        return Colors.tealAccent.value;
      case "Fitness":
        return Colors.deepPurpleAccent.value;
      case "Entertainment":
        return Colors.indigoAccent.value;
      case "Payments":
        return Colors.lightGreenAccent.value;
      default:
        return Colors.blueGrey.value;
    }
  }

  // Import JSON to DB
  Future<void> _importCategoriesOnce() async {
    final db = DBHelper();
    var existing = await db.getAllCategories();

    if (existing.isEmpty) {
      String jsonString = await rootBundle.loadString('assets/data/categories.json');
      Map<String, dynamic> data = json.decode(jsonString);
      List<dynamic> list = data['categories'];

      for (var item in list) {
        await db.insertCategory({
          'name': item['category'],
          'emoji': item['emoji'],
          'macro': item['macro'],
          'keywords': (item['keywords'] as List).join(','), // Save as "milk,doodh,curd"
          'color_value': _getMacroColor(item['macro']),
        });
      }
      _refreshData();
    }
  }

  // Keyword Matcher Engine
  String _getAutoCategory(String input) {
    if (input.isEmpty) return "Misc";
    String cleanInput = input.toLowerCase().trim();

    // Use the _categories list that is already in your State
    for (var cat in _categories) {
      // We check if keywords exist in the map
      if (cat.containsKey('keywords') && cat['keywords'] != null) {
        List<String> keywords = cat['keywords'].toString().split(',');

        if (keywords.any((k) => cleanInput.contains(k.toLowerCase().trim()))) {
          return cat['name'];
        }
      }
    }
    return "Misc"; // Fallback if no keyword matches
  }
}