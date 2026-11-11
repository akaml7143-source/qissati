
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/story_page.dart';
import 'screens/settings_page.dart';
import 'screens/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyStoryApp());
}

class MyStoryApp extends StatefulWidget {
  const MyStoryApp({super.key});

  @override
  State<MyStoryApp> createState() => MyStoryAppState();
}

class MyStoryAppState extends State<MyStoryApp> {
  ThemeMode themeMode = ThemeMode.dark;
  Color accentColor = const Color(0xFFD4AF37);
  double fontSize = 19;
  Locale locale = const Locale('ar');

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedTheme = prefs.getString('moon_theme_mode');
      final savedColor = prefs.getInt('moon_accent_color');
      final savedFontSize = prefs.getDouble('moon_font_size');
      final savedLanguage = prefs.getString('moon_language');

      if (!mounted) return;

      setState(() {
        themeMode =
            savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;

        if (savedColor != null) {
          accentColor = Color(savedColor);
        }

        if (savedFontSize != null) {
          fontSize = savedFontSize.clamp(14.0, 32.0);
        }

        locale = savedLanguage == 'en'
            ? const Locale('en')
            : const Locale('ar');

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'moon_theme_mode',
        themeMode == ThemeMode.light ? 'light' : 'dark',
      );

      await prefs.setInt(
        'moon_accent_color',
        accentColor.toARGB32(),
      );

      await prefs.setDouble('moon_font_size', fontSize);
      await prefs.setString('moon_language', locale.languageCode);
    } catch (_) {}
  }

  void changeTheme(ThemeMode value) {
    setState(() => themeMode = value);
    _saveSettings();
  }

  void changeColor(Color value) {
    setState(() => accentColor = value);
    _saveSettings();
  }

  void changeFontSize(double value) {
    setState(() {
      fontSize = value.clamp(14.0, 32.0);
    });
    _saveSettings();
  }

  void changeLanguage(String value) {
    setState(() => locale = Locale(value));
    _saveSettings();
  }

  Widget _loadingPage() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
        ),
      ),
    );
  }

  Widget _messagePage(
    String title,
    String message, {
    bool showSignOut = false,
    bool showRetry = false,
  }) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.nightlight_round,
                color: Color(0xFFD4AF37),
                size: 65,
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 25),
              if (showRetry)
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              if (showSignOut)
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(color: Color(0xFFD4AF37)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipGate(User user) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('members')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingPage();
        }

        if (snapshot.hasError) {
          return _messagePage(
            'تعذّر التحقق',
            'تحقق من اتصال الإنترنت ثم أعد المحاولة.',
            showSignOut: true,
            showRetry: true,
          );
        }

        final memberData = snapshot.data?.data();
        final isActive = memberData?['active'] == true;

        if (!isActive) {
          return _messagePage(
            'حسابك بانتظار الموافقة',
            'تم تسجيل الدخول بنجاح، لكن عضويتك لم تُفعّل بعد. '
                'يرجى انتظار موافقة مالك التطبيق.',
            showSignOut: true,
          );
        }

        return StoryPage(
          accentColor: accentColor,
          fontSize: fontSize,
          onSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(
                  themeMode: themeMode,
                  accentColor: accentColor,
                  fontSize: fontSize,
                  onThemeChanged: changeTheme,
                  onColorChanged: changeColor,
                  onFontChanged: changeFontSize,
                  onLanguageChanged: changeLanguage,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHome() {
    if (_isLoading) {
      return _loadingPage();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingPage();
        }

        if (snapshot.hasError) {
          return _messagePage(
            'تعذّر التحقق من الحساب',
            'تحقق من اتصال الإنترنت وحاول مرة أخرى.',
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const AuthPage();
        }

        return _buildMembershipGate(user);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFDF7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: accentColor,
        secondary: accentColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFDF7),
        foregroundColor: accentColor,
        centerTitle: true,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: accentColor,
        secondary: accentColor,
        surface: const Color(0xFF111111),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: accentColor,
        centerTitle: true,
        elevation: 0,
      ),
      dividerColor: accentColor.withValues(alpha: 0.45),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'moon',
      locale: locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: _buildHome(),
    );
  }
}
