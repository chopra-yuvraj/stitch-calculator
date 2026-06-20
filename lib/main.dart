import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const StitchCalculatorApp());

class StitchCalculatorApp extends StatelessWidget {
  const StitchCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yuvi Stitch Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E), 
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _stitchCtrl = TextEditingController();
  final _headCtrl   = TextEditingController();
  final _rateCtrl   = TextEditingController();

  String? _result;

  static const _primaryColor = Color(0xFF1A237E); 
  static const _dangerColor  = Color(0xFFC62828); 

  @override
  void dispose() {
    _stitchCtrl.dispose();
    _headCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
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

    final answer = (stitch * head * rate) / 1000.0;
    setState(() => _result = answer.toStringAsFixed(4));
  }

  void _clear() {
    _stitchCtrl.clear();
    _headCtrl.clear();
    _rateCtrl.clear();
    setState(() => _result = null);
  }

  Future<void> _callForHelp() async {
    final uri = Uri(scheme: 'tel', path: '1234567890');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Cannot open the phone dialer.', style: TextStyle(fontSize: 16)),
          backgroundColor: _dangerColor,
        ),
      );
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14), // Reduced spacing
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yuvi Stitch Calculator',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Sleeker title
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20), // More compact padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Stitch Input
              Row(
                children: [
                  const SizedBox(width: 80, child: Text('Stitch:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: _stitchCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Head Input
              Row(
                children: [
                  const SizedBox(width: 80, child: Text('Head:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: _headCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 3: Rate Input
              Row(
                children: [
                  const SizedBox(width: 80, child: Text('Rate:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        controller: _rateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons side by side to save vertical space
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('CALCULATE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _clear,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _dangerColor,
                          side: const BorderSide(color: _dangerColor, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('CLEAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Compact Result Box
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _result == null
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : Container(
                        key: const ValueKey('result'),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _primaryColor, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RESULT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryColor, letterSpacing: 2)),
                                Text('(Stitch × Head × Rate) ÷ 1000', style: TextStyle(fontSize: 11, color: Color(0xFF5C6BC0))),
                              ],
                            ),
                            Text(_result!, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _primaryColor)),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 14),

              // Smaller Support Assistance Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _callForHelp,
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 22),
                  label: const Text('Call Support Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dangerColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
