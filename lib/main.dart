
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

  final List<Color> colors = const [
    Color(0xFFD4AF37),
    Color(0xFF176B70),
    Color(0xFF303B78),
    Color(0xFF1B4332),
    Color(0xFF7B263A),
  ];

  void changeTheme(ThemeMode value) {
    setState(() {
      themeMode = value;
    });
  }

  void changeColor(Color value) {
    setState(() {
      accentColor = value;
    });
  }

  void changeFontSize(double value) {
    setState(() {
      fontSize = value.clamp(14, 32);
    });
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

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFDF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFDF7),
          foregroundColor: Colors.black,
          centerTitle: true,
        ),
      ),

      darkTheme: ThemeData(
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
        dividerColor: const Color(0xFF806B2B),
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
