import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = false;
  String? _message;

  Future<void> _resend() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      setState(() {
        _message = 'تم إرسال رابط التفعيل مجددًا.';
      });
    } catch (e) {
      setState(() {
        _message = 'حدث خطأ أثناء الإرسال.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفعيل البريد الإلكتروني')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('يرجى تفعيل بريدك الإلكتروني عبر الرابط المرسل.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _resend,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('إعادة إرسال الرابط'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!, style: const TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
