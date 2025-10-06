import 'package:flutter/material.dart';

class TwoFAScreen extends StatefulWidget {
  final void Function(String code) onSubmit;
  const TwoFAScreen({super.key, required this.onSubmit});

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _error;
  bool _loading = false;

  void _submit() {
    setState(() {
      _error = null;
      _loading = true;
    });
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() {
        _error = 'الرمز يجب أن يكون 6 أرقام';
        _loading = false;
      });
      return;
    }
    widget.onSubmit(code);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق الثنائي (2FA)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('أدخل رمز التحقق المرسل إلى بريدك أو هاتفك'),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'رمز التحقق'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}
