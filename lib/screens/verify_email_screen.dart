import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = false;
  bool _checkingStatus = false;
  String? _message;
  Color? _messageColor;

  Future<void> _resend() async {
    setState(() {
      _loading = true;
      _message = null;
      _messageColor = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      setState(() {
        _message = 'تم إرسال رابط التفعيل مجددًا.';
        _messageColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _message = 'حدث خطأ أثناء الإرسال.';
        _messageColor = Colors.red;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _checkStatus() async {
    setState(() {
      _checkingStatus = true;
      _message = null;
      _messageColor = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (!mounted) return;
      if (user != null && user.emailVerified) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        setState(() {
          _message = 'لم يتم تفعيل البريد الإلكتروني بعد.';
          _messageColor = Colors.orange[800];
        });
      }
    } catch (e) {
      setState(() {
        _message = 'تعذر التحقق من حالة التفعيل.';
        _messageColor = Colors.red;
      });
    } finally {
      if (mounted) {
        setState(() {
          _checkingStatus = false;
        });
      }
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
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _checkingStatus ? null : _checkStatus,
              child: _checkingStatus
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('تم التفعيل؟ تحديث الحالة'),
            ),
            TextButton(
              onPressed: _checkingStatus
                  ? null
                  : () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (route) => false);
                    },
              child: const Text('تسجيل الخروج'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(
                _message!,
                style: TextStyle(color: _messageColor ?? Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
