
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/story_page.dart';
import 'screens/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  final List<Color> colors = const [
    Color(0xFFD4AF37),
    Color(0xFF176B70),
    Color(0xFF303B78),
    Color(0xFF1B4332),
    Color(0xFF7B263A),
  ];

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
        themeMode = savedTheme == 'light'
            ? ThemeMode.light
            : ThemeMode.dark;

        if (savedColor != null) {
          accentColor = Color(savedColor);
        }

        if (savedFontSize != null) {
          fontSize = savedFontSize.clamp(14.0, 32.0);
        }

        if (savedLanguage == 'en') {
          locale = const Locale('en');
        } else {
          locale = const Locale('ar');
        }

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
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

      await prefs.setDouble(
        'moon_font_size',
        fontSize,
      );

      await prefs.setString(
        'moon_language',
        locale.languageCode,
      );
    } catch (_) {
      // يبقى التطبيق يعمل حتى لو تعذر حفظ الإعدادات.
    }
  }

  void changeTheme(ThemeMode value) {
    setState(() {
      themeMode = value;
    });

    _saveSettings();
  }

  void changeColor(Color value) {
    setState(() {
      accentColor = value;
    });

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
      locale = Locale(value);
    });

    _saveSettings();
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
          ? const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4AF37),
                ),
              ),
            )
          : StoryPage(
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
            ),
    );
  }
}
