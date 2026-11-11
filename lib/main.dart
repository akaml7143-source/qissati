
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
    setState(() => locale = Locale(value));
    _saveSettings();
  }

  void openSettings() {
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
  }

  Future<void> _showWaitingApproval() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191919),
          icon: const Icon(
            Icons.hourglass_top_rounded,
            color: Color(0xFFD4AF37),
            size: 45,
          ),
          title: const Text(
            'حسابك بانتظار الموافقة',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFD4AF37)),
          ),
          content: const Text(
            'تم تسجيل الدخول بنجاح، لكن عضويتك لم تُفعّل بعد. '
            'يرجى انتظار موافقة مالك التطبيق.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.7,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await FirebaseAuth.instance.signOut();
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'إغلاق',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openChatPortal() async {
    if (_openingChat) return;

    setState(() => _openingChat = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      // إذا لم يكن المستخدم مسجلاً، نفتح صفحة الدخول.
      if (user == null) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => const AuthPage(),
          ),
        );

        if (!mounted || result != true) return;

        user = FirebaseAuth.instance.currentUser;
      }

      if (user == null || !mounted) return;

      // فحص موافقة العضوية من Firestore.
      final memberDocument = await FirebaseFirestore.instance
          .collection('members')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final memberData = memberDocument.data();
      final isActive = memberData?['active'] == true;

      if (!isActive) {
        await _showWaitingApproval();
        return;
      }

      // فتح المحادثة بعد التأكد من تفعيل العضوية.
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            accentColor: accentColor,
            fontSize: fontSize,
          ),
        ),
      );
    } on FirebaseAuthException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر التحقق من الحساب. حاول مرة أخرى.'),
        ),
      );
    } on FirebaseException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذّر الاتصال بخدمة العضوية. تحقق من الإنترنت وحاول مجدداً.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ. حاول مرة أخرى.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingChat = false);
      }
    }
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
