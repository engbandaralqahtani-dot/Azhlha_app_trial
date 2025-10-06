import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/password_strength_indicator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;
  String? _error;
  bool _loading = false;

  void _onPasswordChanged(String value) {
    final result = PasswordStrengthIndicator.checkStrength(value);
    setState(() {
      _passwordStrength = result['label']!;
      _strengthColor = result['color']!;
    });
  }

  Future<void> _signup() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _error = 'كلمتا المرور غير متطابقتين';
        _loading = false;
      });
      return;
    }
    if (_passwordStrength == 'ضعيف') {
      setState(() {
        _error = 'كلمة المرور ضعيفة جداً';
        _loading = false;
      });
      return;
    }
    final res = await AuthService.signup(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );
    if (res != null) {
      setState(() {
        _error = res;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم إنشاء الحساب'),
          content:
              const Text('تم إنشاء الحساب بنجاح! يمكنك الآن تسجيل الدخول.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // العودة لشاشة تسجيل الدخول
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل حساب جديد')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'الاسم الكامل'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              onChanged: _onPasswordChanged,
            ),
            PasswordStrengthIndicator(
              strength: _passwordStrength,
              color: _strengthColor,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'رقم الجوال'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      _error == 'حدث خطأ غير متوقع'
                          ? 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.'
                          : _error!,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: _loading ? null : _signup,
                          child: const Text('إعادة المحاولة',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('العودة'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _signup,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('تسجيل'),
            ),
          ],
        ),
      ),
    );
  }
}
