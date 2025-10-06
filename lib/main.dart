import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/accident_provider.dart';
import 'providers/app_provider.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/service_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'widgets/accident_report_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(const AzhlahApp());
  } catch (error, stackTrace) {
    debugPrint('Error initializing Firebase: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'حدث خطأ في تهيئة التطبيق\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ),
      ),
    ));
  }
}

class AzhlahApp extends StatelessWidget {
  const AzhlahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AccidentReportProvider()),
      ],
      child: MaterialApp(
        title: 'أزهلها',
        theme: AppTheme.theme,
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        home: const _AuthGate(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/verify-email': (context) => const VerifyEmailScreen(),
          '/home': (context) => const MainShell(),
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const WelcomeScreen();
        }

        if (!user.emailVerified) {
          return const VerifyEmailScreen();
        }

        return const MainShell();
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final List<Widget> _pages = const [
    HomeScreen(),
    OrdersScreen(),
    ServiceScreen(),
    ProfileScreen(),
  ];

  bool _hasLoadedReports = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedReports) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context
          .read<AccidentReportProvider>()
          .fetchUserReports(user.uid)
          .catchError((error) {
        debugPrint('Failed to load reports: $error');
      });
    }
    _hasLoadedReports = true;
  }

  void _openAccidentReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccidentReportSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final currentIndex = appProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: context.read<AppProvider>().setCurrentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'طلباتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'الخدمات',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openAccidentReportSheet,
              icon: const Icon(Icons.add_alert),
              label: const Text('بلاغ جديد'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
