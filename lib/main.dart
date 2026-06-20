import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const StitchCalculatorApp());

// ─────────────────────────────────────────────────────────────────────────────
// App Root
// ─────────────────────────────────────────────────────────────────────────────

class StitchCalculatorApp extends StatelessWidget {
  const StitchCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stitch Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Light grey background — easy on elderly eyes, high contrast
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E), // Deep indigo — strong contrast
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Calculator Screen (single screen, fully stateful)
// ─────────────────────────────────────────────────────────────────────────────

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // One controller per input field
  final _stitchCtrl = TextEditingController();
  final _headCtrl   = TextEditingController();
  final _rateCtrl   = TextEditingController();

  // Holds the computed result string; null means "not calculated yet"
  String? _result;

  // Brand colours — defined once, used everywhere
  static const _primaryColor = Color(0xFF1A237E); // Deep indigo
  static const _dangerColor  = Color(0xFFC62828); // Deep red

  // Always dispose controllers to avoid memory leaks
  @override
  void dispose() {
    _stitchCtrl.dispose();
    _headCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  // ─── Business Logic ────────────────────────────────────────────────────────

  void _calculate() {
    // double.tryParse returns null for empty or non-numeric input
    final stitch = double.tryParse(_stitchCtrl.text.trim());
    final head   = double.tryParse(_headCtrl.text.trim());
    final rate   = double.tryParse(_rateCtrl.text.trim());

    if (stitch == null || head == null || rate == null) {
      _showAlert(
        'Missing Values',
        'Please enter a valid number in every field before calculating.',
      );
      return;
    }

    // Formula: (Stitch × Head × Rate) ÷ 1000
    final answer = (stitch * head * rate) / 1000.0;

    // Show 4 decimal places so the result is precise
    setState(() => _result = answer.toStringAsFixed(4));
  }

  void _clear() {
    _stitchCtrl.clear();
    _headCtrl.clear();
    _rateCtrl.clear();
    setState(() => _result = null);
  }

  // Opens the phone dialer with the support number pre-filled
  Future<void> _callForHelp() async {
    final uri = Uri(scheme: 'tel', path: '8000444255');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: show a visible error if the dialer can't be opened
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️  Cannot open the phone dialer on this device.',
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: _dangerColor,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold),
        ),
        content:
            Text(message, style: const TextStyle(fontSize: 22)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
  }

  // ─── UI Helper — builds one labelled numeric input field ───────────────────

  Widget _inputField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label — bold, at least 24 sp (accessibility requirement)
          Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            // Opens NUMERIC keypad only — no confusing letter keys
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            // Only allow digits and a single decimal point
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            // Large font inside the field so it's easy to see what was typed
            style: const TextStyle(
                fontSize: 28, color: Color(0xFF0D0D0D)),
            decoration: InputDecoration(
              hintText: 'Enter value…',
              hintStyle: const TextStyle(
                  fontSize: 22, color: Color(0xFFBDBDBD)),
              // Tall padding creates a large, finger-friendly touch target
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 22),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: _primaryColor, width: 3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF9E9E9E), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stitch Calculator',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Three input fields ─────────────────────────────────────────
              _inputField('Stitch', _stitchCtrl),
              _inputField('Head',   _headCtrl),
              _inputField('Rate',   _rateCtrl),
              const SizedBox(height: 8),

              // ── CALCULATE button ───────────────────────────────────────────
              SizedBox(
                height: 72, // Large touch target
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_rounded, size: 34),
                  label: const Text(
                    'CALCULATE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 5,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── CLEAR button ───────────────────────────────────────────────
              SizedBox(
                height: 66,
                child: OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear_rounded, size: 30),
                  label: const Text(
                    'CLEAR',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _dangerColor,
                    side: const BorderSide(
                        color: _dangerColor, width: 2.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ── Result box — fades in after calculation ────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _result == null
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : Container(
                        key: const ValueKey('result'),
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6), // Soft indigo tint
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: _primaryColor, width: 2.5),
                        ),
                        child: Column(
                          children: [
                            // "RESULT" label
                            const Text(
                              'RESULT',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _primaryColor,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // The number itself — 64 sp, bold, impossible to miss
                            Text(
                              _result!,
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Formula reminder so the user knows what they calculated
                            const Text(
                              '(Stitch × Head × Rate) ÷ 1000',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF5C6BC0)),
                            ),
                          ],
                        ),
                      ),
              ),

              // ── Visual separator before the help button ────────────────────
              const SizedBox(height: 32),
              const Divider(thickness: 1.5),
              const SizedBox(height: 20),

              // ── CALL FOR HELP button ───────────────────────────────────────
              // Prominent red, 80 dp tall, phone icon — immediately visible
              SizedBox(
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: _callForHelp,
                  icon: const Icon(
                      Icons.phone_in_talk_rounded, size: 40),
                  label: const Text(
                    'CALL FOR HELP',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dangerColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Small caption showing the number so users know who they'll call
              const Center(
                child: Text(
                  'Tap to call: 1234567890',
                  style: TextStyle(
                      fontSize: 18, color: Color(0xFF757575)),
                ),
              ),
              const SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }
}