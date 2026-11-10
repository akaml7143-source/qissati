
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/story_page.dart';
import 'screens/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyStoryApp());
}

class MyStoryApp extends StatefulWidget {
  const MyStoryApp({super.key});

  @override
  State<MyStoryApp> createState() => MyStoryAppState();
}

class MyStoryAppState extends State<MyStoryApp> {
  ThemeMode themeMode = ThemeMode.light;

  Color accentColor = const Color(0xFFF1AFCB);

  double fontSize = 19;

  Locale locale = const Locale('ar');

  final List<Color> colors = const [
    Color(0xFFF1AFCB),
    Color(0xFF176B70),
    Color(0xFF303B78),
    Color(0xFF1B4332),
    Color(0xFF7B263A),
  ];

  void changeTheme(ThemeMode value) {
    setState(() => themeMode = value);
  }

  void changeColor(Color value) {
    setState(() => accentColor = value);
  }

  void changeFontSize(double value) {
    setState(() => fontSize = value);
  }

  void changeLanguage(String value) {
    setState(() {
      locale = Locale(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MY STORY',

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

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFF8FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ),
      ),

      home: StoryPage(
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

