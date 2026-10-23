import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OshudhReminderApp());
}

// ---------------- Bangla Helpers ----------------

String bn(Object v) {
  const digits = '০১২৩৪৫৬৭৮৯';
  final out = StringBuffer();
  for (final ch in v.toString().split('')) {
    final i = int.tryParse(ch);
    out.write(i == null ? ch : digits[i]);
  }
  return out.toString();
}

String bnTime(DateTime t) {
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final String period;
  if (t.hour < 4) {
    period = 'রাত';
  } else if (t.hour < 6) {
    period = 'ভোর';
  } else if (t.hour < 12) {
    period = 'সকাল';
  } else if (t.hour < 15) {
    period = 'দুপুর';
  } else if (t.hour < 18) {
    period = 'বিকাল';
  } else if (t.hour < 20) {
    period = 'সন্ধ্যা';
  } else {
    period = 'রাত';
  }
  return '$period ${bn(h12)}:${bn(t.minute.toString().padLeft(2, '0'))}';
}

// ---------------- Widget Sync Helper ----------------

Future<void> updateHomeScreenWidget({
  required String nextMedName,
  required String nextMedTime,
  required String status,
}) async {
  try {
    await HomeWidget.saveWidgetData<String>('next_med_name', nextMedName);
    await HomeWidget.saveWidgetData<String>('next_med_time', nextMedTime);
    await HomeWidget.saveWidgetData<String>('med_status', status);
    await HomeWidget.updateWidget(
      name: 'OshudhWidgetProvider',
      androidName: 'OshudhWidgetProvider',
    );
  } catch (e) {
    debugPrint('Widget Update Error: $e');
  }
}

// ---------------- Models ----------------

enum SlotType { morning, noon, night }

class Medicine {
  Medicine({
    required this.id,
    required this.name,
    required this.slot,
    required this.timeText,
    required this.timing,
    required this.dose,
  });
  final int id;
  String name;
  SlotType slot;
  String timeText;
  String timing;
  String dose;
}

// ---------------- Main App Entry ----------------

class OshudhReminderApp extends StatelessWidget {
  const OshudhReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ওষুধ রিমাইন্ডার',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00796B),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F7F6),
        textTheme: GoogleFonts.hindSiliguriTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// ---------------- 1. Auth & Account Binding Screen ----------------

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSupervisor = false;
  final TextEditingController _nameController = TextEditingController(text: 'আম্মা');
  final TextEditingController _codeController = TextEditingController(text: 'REM-9821');

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainDashboard(
          parentName: _nameController.text.trim().isEmpty ? 'আম্মা' : _nameController.text.trim(),
          isSupervisor: isSupervisor,
          pairCode: _codeController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.teal.shade200, width: 2),
                  ),
                  child: const Icon(Icons.medication_rounded, size: 64, color: Color(0xFF00796B)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'ওষুধ রিমাইন্ডার',
                  style: GoogleFonts.hindSiliguri(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
                ),
              ),
              Center(
                child: Text(
                  'বাবা-মায়ের সহজ ও সুরক্ষিত ওষুধ রিমাইন্ডার অ্যাপ',
                  style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 32),

              Text('আপনার ভূমিকা (Role) নির্বাচন করুন:', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('বাবা / মা', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      selected: !isSupervisor,
                      onSelected: (val) => setState(() => isSupervisor = !val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('সন্তান / তত্ত্বাবধায়ক', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      selected: isSupervisor,
                      onSelected: (val) => setState(() => isSupervisor = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (!isSupervisor) ...[
                TextField(
                  controller: _nameController,
                  style: GoogleFonts.hindSiliguri(fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'আপনার নাম (যেমন: আম্মা / আব্বু)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('আপনার বাইন্ডিং কোড:', style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.black54)),
                          Text('REM-9821', style: GoogleFonts.hindSiliguri(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF00796B))),
                        ],
                      ),
                      const Icon(Icons.qr_code_scanner, size: 40, color: Color(0xFF00796B)),
                    ],
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _codeController,
                  style: GoogleFonts.hindSiliguri(fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'বাবা/মায়ের কানেকশন কোড লিখুন',
                    hintText: 'যেমন: REM-9821',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phonelink_ring),
                  ),
                ),
                const SizedBox(height: 8),
                Text('এই মোডে আপনি শুধু রিমোটলি মনিটর করতে পারবেন, কোনো ওষুধ পরিবর্তন বা টিক দিতে পারবেন না।', style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.black54)),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.login, size: 24),
                  label: Text(
                    isSupervisor ? 'মনিটরিং ড্যাশবোর্ড খুলুন' : 'অ্যাপ চালু করুন',
                    style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- 2. Main Dashboard ----------------

class MainDashboard extends StatefulWidget {
  const MainDashboard({
    super.key,
    required this.parentName,
    required this.isSupervisor,
    required this.pairCode,
  });

  final String parentName;
  final bool isSupervisor;
  final String pairCode;

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> with SingleTickerProviderStateMixin {
  int _currentTab = 0;

  final List<Medicine> _meds = [
    Medicine(id: 1, name: 'নাপা এক্সটেন্ড (Napa)', slot: SlotType.morning, timeText: 'সকাল ৮:০০ টা', timing: 'খাওয়ার পরে', dose: '১টি ট্যাবলেট'),
    Medicine(id: 2, name: 'সেক্লো ২০ (Seclo)', slot: SlotType.morning, timeText: 'সকাল ৮:৩০ টা', timing: 'খাওয়ার আগে', dose: '১টি ক্যাপসুল'),
    Medicine(id: 3, name: 'অ্যামলোডিপিন (Amlo)', slot: SlotType.noon, timeText: 'দুপুর ২:০০ টা', timing: 'খাওয়ার পরে', dose: '১টি ট্যাবলেট'),
    Medicine(id: 4, name: 'রোজুভাস্ট ১০ (Rosu)', slot: SlotType.night, timeText: 'রাত ৯:৩০ টা', timing: 'খাওয়ার পরে', dose: '১টি ট্যাবলেট'),
  ];

  final Map<int, DateTime> _takenLogs = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _syncWidgetData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _syncWidgetData() {
    final pendingMeds = _meds.where((m) => !_takenLogs.containsKey(m.id)).toList();
    if (pendingMeds.isNotEmpty) {
      final current = pendingMeds.first;
      updateHomeScreenWidget(
        nextMedName: current.name,
        nextMedTime: current.timeText,
        status: 'এখন খাওয়ার সময়',
      );
    } else {
      updateHomeScreenWidget(
        nextMedName: 'সব সম্পন্ন!',
        nextMedTime: '🎉',
        status: 'আজকের সব ওষুধ খাওয়া শেষ',
      );
    }
  }

  void _toggleTake(int medId) {
    if (widget.isSupervisor) return;

    setState(() {
      if (_takenLogs.containsKey(medId)) {
        _takenLogs.remove(medId);
      } else {
        _takenLogs[medId] = DateTime.now();
      }
    });

    _syncWidgetData();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _takenLogs.containsKey(medId) ? '✓ সময়মতো ওষুধ গ্রহণ রেকর্ড করা হয়েছে!' : 'স্ট্যাটাস পরিবর্তন করা হয়েছে',
          style: GoogleFonts.hindSiliguri(fontSize: 16),
        ),
        backgroundColor: const Color(0xFF00796B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final timeController = TextEditingController(text: 'সকাল ৯:০০ টা');
    final doseController = TextEditingController(text: '১টি ট্যাবলেট');
    SlotType selectedSlot = SlotType.morning;
    String selectedTiming = 'খাওয়ার পরে';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('নতুন ওষুধ যোগ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ওষুধের নাম (যেমন: Napa)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'সময় (যেমন: সকাল ৯:০০ টা)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: doseController,
                decoration: const InputDecoration(labelText: 'মাত্রা (যেমন: ১টি ট্যাবলেট)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<SlotType>(
                value: selectedSlot,
                items: const [
                  DropdownMenuItem(value: SlotType.morning, child: Text('সকাল')),
                  DropdownMenuItem(value: SlotType.noon, child: Text('দুপুর')),
                  DropdownMenuItem(value: SlotType.night, child: Text('রাত')),
                ],
                onChanged: (val) => selectedSlot = val ?? SlotType.morning,
                decoration: const InputDecoration(labelText: 'সময়ের স্লট'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedTiming,
                items: const [
                  DropdownMenuItem(value: 'খাওয়ার পরে', child: Text('খাওয়ার পরে')),
                  DropdownMenuItem(value: 'খাওয়ার আগে', child: Text('খাওয়ার আগে')),
                ],
                onChanged: (val) => selectedTiming = val ?? 'খাওয়ার পরে',
                decoration: const InputDecoration(labelText: 'খাওয়ার নিয়ম'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _meds.add(
                    Medicine(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: nameController.text.trim(),
                      slot: selectedSlot,
                      timeText: timeController.text.trim(),
                      timing: selectedTiming,
                      dose: doseController.text.trim(),
                    ),
                  );
                });
                _syncWidgetData();
                Navigator.pop(context);
              }
            },
            child: const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }

  BoxDecoration _getSlotCardDecoration(SlotType slot) {
    switch (slot) {
      case SlotType.morning:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.orange.shade300, width: 1.5),
        );
      case SlotType.noon:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.lightBlue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.lightBlue.shade300, width: 1.5),
        );
      case SlotType.night:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF283593)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.indigo.shade200, width: 1.5),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSupervisor ? '${widget.parentName}-র মনিটরিং (ReadOnly)' : 'ওষুধ রিমাইন্ডার (${widget.parentName})',
          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00796B),
        elevation: 0,
        actions: [
          if (!widget.isSupervisor)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
              tooltip: 'ওষুধ যোগ করুন',
              onPressed: _showAddMedicineDialog,
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
          )
        ],
      ),
      body: _currentTab == 0 ? _buildMainView() : _buildProfessionalReportView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.medication),
            label: widget.isSupervisor ? 'মনিটরিং ফিড' : 'আজকের ওষুধ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics),
            label: 'হেলথ রিপোর্ট',
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    final pendingMeds = _meds.where((m) => !_takenLogs.containsKey(m.id)).toList();
    final currentMed = pendingMeds.isNotEmpty ? pendingMeds.first : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSupervisor ? Colors.amber.shade50 : Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.isSupervisor ? Colors.amber.shade300 : Colors.teal.shade200),
          ),
          child: Row(
            children: [
              Icon(
                widget.isSupervisor ? Icons.visibility : Icons.sensors,
                color: widget.isSupervisor ? Colors.amber.shade800 : const Color(0xFF00796B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.isSupervisor
                      ? 'মনিটরিং মোড: আপনি শুধু দেখতে পাচ্ছেন (কোড: ${widget.pairCode})'
                      : 'লাইভ সিঙ্ক চালু আছে (কোড: ${widget.pairCode})',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: widget.isSupervisor ? Colors.amber.shade900 : const Color(0xFF004D40),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (currentMed != null) ...[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: _getSlotCardDecoration(currentMed.slot),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentMed.slot == SlotType.morning
                          ? Icons.wb_twilight
                          : currentMed.slot == SlotType.noon
                              ? Icons.wb_sunny
                              : Icons.nightlight_round,
                      color: currentMed.slot == SlotType.night ? Colors.amberAccent : Colors.deepOrange,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isSupervisor ? 'পরবর্তী খাওয়ার সময় (${currentMed.timeText})' : 'এখন খাওয়ার সময় (${currentMed.timeText})',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentMed.slot == SlotType.night ? Colors.amberAccent : Colors.brown.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentMed.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: currentMed.slot == SlotType.night ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'নিয়ম: ${currentMed.timing} • ${currentMed.dose}',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: currentMed.slot == SlotType.night ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                if (!widget.isSupervisor)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _toggleTake(currentMed.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentMed.slot == SlotType.night ? Colors.amberAccent : const Color(0xFF00796B),
                        foregroundColor: currentMed.slot == SlotType.night ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.check_circle, size: 30),
                      label: Text(
                        'খেয়েছেন?',
                        style: GoogleFonts.hindSiliguri(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'তত্ত্বাবধায়ক হিসেবে আপনি এখানে টিক দিতে পারবেন না।',
                      style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          )
        ] else ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline, size: 64, color: Colors.greenAccent),
                const SizedBox(height: 8),
                Text(
                  'আজকের সব ওষুধ খাওয়া সম্পন্ন! 🎉',
                  style: GoogleFonts.hindSiliguri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          )
        ],

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ওষুধের তালিকা:', style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold)),
            if (!widget.isSupervisor)
              TextButton.icon(
                onPressed: _showAddMedicineDialog,
                icon: const Icon(Icons.add),
                label: Text('নতুন যোগ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 10),

        for (final m in _meds) ...[
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            color: _takenLogs.containsKey(m.id) ? Colors.green.shade50 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                m.name,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: _takenLogs.containsKey(m.id) ? TextDecoration.lineThrough : null,
                  color: _takenLogs.containsKey(m.id) ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text(
                '${m.timeText} • ${m.timing} • ${m.dose}',
                style: GoogleFonts.hindSiliguri(fontSize: 14),
              ),
              trailing: _takenLogs.containsKey(m.id)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('খেয়েছেন ✓', style: GoogleFonts.hindSiliguri(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(bnTime(_takenLogs[m.id]!), style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.black54)),
                      ],
                    )
                  : widget.isSupervisor
                      ? Text('pending', style: GoogleFonts.hindSiliguri(color: Colors.orange, fontWeight: FontWeight.bold))
                      : ElevatedButton(
                          onPressed: () => _toggleTake(m.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00796B),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('খেয়েছেন?', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                        ),
            ),
          )
        ]
      ],
    );
  }

  Widget _buildProfessionalReportView() {
    final total = _meds.length;
    final takenCount = _takenLogs.length;
    final double adherenceRate = total == 0 ? 0.0 : (takenCount / total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('হেলথ ও ওষুধ গ্রহণের অ্যানালিটিক্স', style: GoogleFonts.hindSiliguri(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(widget.isSupervisor ? '(${widget.parentName}-র লাইভ স্বাস্থ্য প্রতিবেদন)' : 'আজকের বিস্তারিত প্রতিবেদন', style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 16),

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('দৈনিক কমপ্লায়েন্স স্কোর', style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey.shade700)),
                        Text(
                          '${bn((adherenceRate * 100).toInt())}%',
                          style: GoogleFonts.hindSiliguri(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF00796B)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: adherenceRate >= 0.8 ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        adherenceRate >= 0.8 ? 'খুব ভালো 🌟' : 'সতর্কতা প্রয়োজন ⚠️',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: adherenceRate >= 0.8 ? Colors.green.shade900 : Colors.orange.shade900,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: adherenceRate,
                    minHeight: 14,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'মোট ${bn(total)}টির মধ্যে ${bn(takenCount)}টি ওষুধ সময়মতো গ্রহণ করা হয়েছে।',
                  style: GoogleFonts.hindSiliguri(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        Text('সাপ্তাহিক ট্র্যাকিং গ্রাফ', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('শনি', 0.9),
              _buildBar('রবি', 1.0),
              _buildBar('সোম', 0.75),
              _buildBar('মঙ্গল', 0.85),
              _buildBar('বুধ', 1.0),
              _buildBar('বৃহঃ', 0.60),
              _buildBar('আজ', adherenceRate, isCurrent: true),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text('রিয়েল-টাইম লগ ফিড', style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        for (final m in _meds) ...[
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(
                _takenLogs.containsKey(m.id) ? Icons.check_circle : Icons.pending_actions,
                color: _takenLogs.containsKey(m.id) ? Colors.green : Colors.orange,
                size: 32,
              ),
              title: Text(m.name, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('${m.timeText} • ${m.timing}', style: GoogleFonts.hindSiliguri(fontSize: 14)),
              trailing: Text(
                _takenLogs.containsKey(m.id)
                    ? 'খেয়েছেন\n(${bnTime(_takenLogs[m.id]!)})'
                    : 'এখনো খাননি',
                textAlign: TextAlign.right,
                style: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _takenLogs.containsKey(m.id) ? Colors.green : Colors.red,
                ),
              ),
            ),
          )
        ]
      ],
    );
  }

  Widget _buildBar(String day, double ratio, {bool isCurrent = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 100 * ratio,
          width: 18,
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFF00796B) : Colors.teal.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: GoogleFonts.hindSiliguri(
            fontSize: 13,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? const Color(0xFF00796B) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
