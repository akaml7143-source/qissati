
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
import 'screens/chat_page.dart';

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
  State<MyStoryApp> createState() => _MyStoryAppState();
}

class _MyStoryAppState extends State<MyStoryApp> {
  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  ThemeMode themeMode = ThemeMode.dark;
  Color accentColor = const Color(0xFFD4AF37);
  double fontSize = 19;
  Locale locale = const Locale('ar');

  bool _isLoading = true;
  bool _openingChat = false;

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
    setState(() {
      locale = value == 'en'
          ? const Locale('en')
          : const Locale('ar');
    });
    _saveSettings();
  }

  void openSettings() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
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
  }

  void _openChatPortal() {
    _handleOpenChat();
  }

  Future<void> _handleOpenChat() async {
    if (_openingChat || !mounted) return;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    _openingChat = true;

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        final result = await navigator.push<bool>(
          MaterialPageRoute(
            builder: (_) => const AuthPage(),
          ),
        );

        if (!mounted) return;

        if (result != true) return;

        user = FirebaseAuth.instance.currentUser;
      }

      if (user == null) {
        _showMessage('يرجى تسجيل الدخول أولاً.');
        return;
      }

      final memberDocument = await FirebaseFirestore.instance
          .collection('members')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = memberDocument.data();

      final isActive = memberDocument.exists &&
          data != null &&
          data['active'] == true;

      if (!isActive) {
        await _showWaitingApproval();
        return;
      }

      if (!mounted) return;

      await _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            accentColor: accentColor,
            fontSize: fontSize,
          ),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(
        e.code == 'permission-denied'
            ? 'لا توجد صلاحية للوصول إلى الحساب. يرجى مراجعة المسؤول.'
            : 'تعذّر الاتصال بالخدمة. تحقق من الإنترنت وحاول مجدداً.',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('حدث خطأ غير متوقع. حاول مرة أخرى.');
    } finally {
      _openingChat = false;
    }
  }

  Future<void> _showWaitingApproval() async {
    if (!mounted) return;

    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) return;

    await showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          title: const Text(
            'الحساب بانتظار الموافقة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'تم تسجيل الدخول، لكن لم تتم الموافقة على عضوية هذا الحساب بعد.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'حسناً',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF252525),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _loadingPage() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: accentColor,
        ),
      ),
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
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _messengerKey,
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
      home: _isLoading
          ? _loadingPage()
          : StoryPage(
              accentColor: accentColor,
              fontSize: fontSize,
              onSettings: openSettings,
              onOpenChat: _openChatPortal,
            ),
    );
  }
}
