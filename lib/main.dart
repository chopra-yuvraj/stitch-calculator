import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const StitchCalculatorApp());
}

class StitchCalculatorApp extends StatelessWidget {
  const StitchCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yuvi Stitch Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          background: const Color(0xFFF3F4F6),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
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
  final _headCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  String? _result;

  // Premium Color Palette
  static const _primary = Color(0xFF1A237E);
  static const _danger = Color(0xFFE53935);
  static const _surface = Colors.white;
  static const _textPrimary = Color(0xFF1F2937);
  static const _textSecondary = Color(0xFF6B7280);

  @override
  void dispose() {
    _stitchCtrl.dispose();
    _headCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    // Dismiss keyboard for a clean view of the result
    FocusManager.instance.primaryFocus?.unfocus();

    final stitch = double.tryParse(_stitchCtrl.text.trim());
    final head = double.tryParse(_headCtrl.text.trim());
    final rate = double.tryParse(_rateCtrl.text.trim());

    if (stitch == null || head == null || rate == null) {
      _showErrorSnackBar('Please enter valid numbers in all fields.');
      return;
    }

    final answer = (stitch * head * rate) / 1000.0;
    setState(() => _result = answer.toStringAsFixed(4));
  }

  void _clear() {
    FocusManager.instance.primaryFocus?.unfocus();
    _stitchCtrl.clear();
    _headCtrl.clear();
    _rateCtrl.clear();
    setState(() => _result = null);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 16))),
          ],
        ),
        backgroundColor: _danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _callForHelp() async {
    final uri = Uri(scheme: 'tel', path: '1234567890');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      _showErrorSnackBar('Cannot open the phone dialer on this device.');
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _textSecondary, fontSize: 16),
          prefixIcon: Icon(icon, color: _primary.withOpacity(0.7)),
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yuvi Stitch Calculator',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Input Card
              Container(
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInputField(label: 'Stitch Value', controller: _stitchCtrl, icon: Icons.straighten),
                    _buildInputField(label: 'Head Value', controller: _headCtrl, icon: Icons.precision_manufacturing),
                    _buildInputField(label: 'Rate Value', controller: _rateCtrl, icon: Icons.currency_rupee),
                    
                    const SizedBox(height: 8),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            onPressed: _calculate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('CALCULATE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: OutlinedButton(
                            onPressed: _clear,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.shade300, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('CLEAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Animated Result Display
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _result == null
                    ? const SizedBox.shrink()
                    : Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'FINAL RESULT',
                              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _result!,
                              style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '(Stitch × Head × Rate) ÷ 1000',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 32),

              // Support Assistant Button
              ElevatedButton.icon(
                onPressed: _callForHelp,
                icon: const Icon(Icons.support_agent, size: 24),
                label: const Text('Call Support Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _surface,
                  foregroundColor: _danger,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: _danger, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
