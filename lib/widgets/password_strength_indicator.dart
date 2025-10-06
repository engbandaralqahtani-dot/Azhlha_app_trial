import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String strength;
  final Color color;
  const PasswordStrengthIndicator(
      {super.key, required this.strength, required this.color});

  static Map<String, dynamic> checkStrength(String password) {
    bool hasMin = password.length >= 8;
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'\d'));
    bool hasSymbol =
        password.contains(RegExp(r'[!@#\$&*~%^()_+=\-\[\]{}|;:,.<>?]'));
    int score = [hasMin, hasLower, hasUpper, hasDigit, hasSymbol]
        .where((b) => b)
        .length;
    if (!hasMin || !hasLower || !hasUpper || !hasDigit || !hasSymbol) {
      return {'label': 'ضعيف', 'color': Colors.red};
    } else if (score == 5 && password.length >= 12) {
      return {'label': 'قوي', 'color': Colors.green};
    } else {
      return {'label': 'متوسط', 'color': Colors.orange};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (strength.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        const Text('قوة كلمة المرور: ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text(strength,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
