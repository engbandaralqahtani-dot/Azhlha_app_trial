import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على المستخدم الحالي
  static User? get currentUser => _auth.currentUser;

  // Stream لمراقبة حالة تسجيل الدخول
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static Future<String?> signup(
    String email,
    String password, {
    required String name,
    required String phoneNumber,
    String userType = 'customer',
  }) async {
    try {
      // إنشاء حساب المستخدم
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return 'فشل في إنشاء الحساب';
      }

      // إنشاء وثيقة المستخدم في Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // إرسال رسالة تأكيد البريد الإلكتروني
      await userCredential.user!.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'البريد الإلكتروني مستخدم مسبقًا';
      } else if (e.code == 'invalid-email') {
        return 'البريد الإلكتروني غير صالح';
      } else if (e.code == 'weak-password') {
        return 'كلمة المرور ضعيفة جداً';
      } else if (e.code == 'operation-not-allowed') {
        return 'تم تعطيل إنشاء الحسابات مؤقتاً';
      }
      return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا: ${e.message}';
    } catch (e) {
      return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا';
    }
  }

  static Future<String?> login(String email, String password) async {
    try {
      // محاولة تسجيل الدخول
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCred.user == null) {
        return 'فشل في تسجيل الدخول';
      }

      // التحقق من تأكيد البريد الإلكتروني
      if (!userCred.user!.emailVerified) {
        await _auth.signOut();
        return 'يجب تفعيل البريد الإلكتروني أولاً.';
      }

      // تحديث آخر تسجيل دخول
      await _firestore.collection('users').doc(userCred.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'البريد الإلكتروني غير مسجل';
      } else if (e.code == 'wrong-password') {
        return 'كلمة المرور غير صحيحة';
      } else if (e.code == 'user-disabled') {
        return 'تم تعطيل هذا الحساب';
      } else if (e.code == 'too-many-requests') {
        return 'تم حظر الوصول مؤقتاً بسبب كثرة المحاولات. الرجاء المحاولة لاحقاً';
      }
      return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا: ${e.message}';
    } catch (e) {
      return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا';
    }
  }

  static Future<String?> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return null; // لأسباب أمنية لا نكشف أن البريد غير مسجل
      }
      return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا.';
    } catch (e) {
      return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا.';
    }
  }

  static Future<String?> resendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      return null;
    } catch (e) {
      return 'حدث خطأ أثناء إعادة إرسال رابط التفعيل.';
    }
  }
}
