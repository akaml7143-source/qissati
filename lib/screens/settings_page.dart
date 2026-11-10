
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ThemeMode themeMode;
  final Color accentColor;
  final double fontSize;

  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onFontChanged;
  final ValueChanged<String> onLanguageChanged;

  const SettingsPage({
    super.key,
    required this.themeMode,
    required this.accentColor,
    required this.fontSize,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onFontChanged,
    required this.onLanguageChanged,
  });

  static const List<Color> colors = [
    Color(0xFFF1AFCB),
    Color(0xFF176B70),
    Color(0xFF303B78),
    Color(0xFF1B4332),
    Color(0xFF7B263A),
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final dark = themeMode == ThemeMode.dark;

    final textColor =
        Theme.of(context).colorScheme.onSurface;

    return Directionality(
      textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'الإعدادات' : 'Settings'),
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          elevation: 1,
        ),

        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _sectionTitle(
              isArabic ? 'المظهر' : 'Appearance',
              Icons.palette_outlined,
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    title: Text(
                      isArabic ? 'الوضع النهاري' : 'Light mode',
                    ),
                    secondary: const Icon(Icons.light_mode),
                    onChanged: (value) {
                      if (value != null) {
                        onThemeChanged(value);
                      }
                    },
                  ),

                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    title: Text(
                      isArabic ? 'الوضع الليلي' : 'Dark mode',
                    ),
                    secondary: const Icon(Icons.dark_mode),
                    onChanged: (value) {
                      if (value != null) {
                        onThemeChanged(value);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle(
              isArabic ? 'الألوان' : 'Colors',
              Icons.color_lens_outlined,
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  children: colors.map((color) {
                    final selected =
                        color.toARGB32() ==
                        accentColor.toARGB32();

                    return GestureDetector(
                      onTap: () => onColorChanged(color),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 220,
                        ),
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? textColor
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.35),
                              blurRadius: selected ? 10 : 3,
                            ),
                          ],
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle(
              isArabic ? 'حجم الخط' : 'Font size',
              Icons.format_size,
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      isArabic
                          ? 'معاينة حجم الخط'
                          : 'Font size preview',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      isArabic
                          ? 'هذه قصتي الجميلة'
                          : 'This is my story',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                      ),
                    ),

                    Slider(
                      value: fontSize.clamp(16.0, 32.0),
                      min: 16,
                      max: 32,
                      divisions: 16,
                      label: fontSize.round().toString(),
                      activeColor: accentColor,
                      onChanged: onFontChanged,
                    ),

                    Text(
                      '${fontSize.round()}',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle(
              isArabic ? 'اللغة' : 'Language',
              Icons.language,
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Text(
                      '🇮🇶',
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text('العربية'),
                    trailing: isArabic
                        ? Icon(
                            Icons.check_circle,
                            color: accentColor,
                          )
                        : null,
                    onTap: () => onLanguageChanged('ar'),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Text(
                      '🇬🇧',
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text('English'),
                    trailing: !isArabic
                        ? Icon(
                            Icons.check_circle,
                            color: accentColor,
                          )
                        : null,
                    onTap: () => onLanguageChanged('en'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                'MY STORY',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: accentColor),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

