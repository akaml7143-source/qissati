
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
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

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Colors.black;
  static const Color cardColor = Color(0xFF111111);

  late ThemeMode selectedTheme;
  late Color selectedColor;
  late double selectedFontSize;

  final List<Color> colors = const [
    Color(0xFFD4AF37),
    Color(0xFFF1AFCB),
    Color(0xFF176B70),
    Color(0xFF303B78),
    Color(0xFF1B4332),
    Color(0xFF7B263A),
  ];

  @override
  void initState() {
    super.initState();
    selectedTheme = widget.themeMode;
    selectedColor = widget.accentColor;
    selectedFontSize = widget.fontSize;
  }

  bool get isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  String tr(String ar, String en) => isArabic ? ar : en;

  void selectTheme(ThemeMode value) {
    setState(() => selectedTheme = value);
    widget.onThemeChanged(value);
  }

  void selectColor(Color value) {
    setState(() => selectedColor = value);
    widget.onColorChanged(value);
  }

  void selectFont(double value) {
    setState(() => selectedFontSize = value);
    widget.onFontChanged(value);
  }

  void selectLanguage(String value) {
    widget.onLanguageChanged(value);
  }

  void comingSoon(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          title,
          style: const TextStyle(color: gold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          tr(
            'هذا القسم سنفعّله في المرحلة القادمة بعد تجهيز وظيفته.',
            'This section will be enabled in a future development stage.',
          ),
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              tr('حسناً', 'OK'),
              style: const TextStyle(color: gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: gold.withValues(alpha: 0.35),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: gold),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: const TextStyle(color: Colors.white54),
            ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white38,
            size: 16,
          ),
      onTap: onTap,
    );
  }

  Widget buildAppearance() {
    return settingsCard([
      RadioListTile<ThemeMode>(
        value: ThemeMode.dark,
        groupValue: selectedTheme,
        activeColor: gold,
        secondary: const Icon(
          Icons.dark_mode,
          color: gold,
        ),
        title: Text(
          tr('الوضع الليلي', 'Dark mode'),
          style: const TextStyle(color: Colors.white),
        ),
        onChanged: (value) {
          if (value != null) selectTheme(value);
        },
      ),
      const Divider(color: Colors.white12, height: 1),
      RadioListTile<ThemeMode>(
        value: ThemeMode.light,
        groupValue: selectedTheme,
        activeColor: gold,
        secondary: const Icon(
          Icons.light_mode,
          color: gold,
        ),
        title: Text(
          tr('الوضع النهاري', 'Light mode'),
          style: const TextStyle(color: Colors.white),
        ),
        onChanged: (value) {
          if (value != null) selectTheme(value);
        },
      ),
    ]);
  }

  Widget buildColors() {
    return settingsCard([
      Padding(
        padding: const EdgeInsets.all(17),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 18,
          children: colors.map((color) {
            final selected =
                color.toARGB32() == selectedColor.toARGB32();

            return GestureDetector(
              onTap: () => selectColor(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
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
    ]);
  }

  Widget buildFontSettings() {
    return settingsCard([
      Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          children: [
            Text(
              tr('معاينة حجم الخط', 'Font size preview'),
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              tr('لكل منا قصة جميلة', 'Everyone has a story'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: selectedFontSize,
              ),
            ),
            Slider(
              value: selectedFontSize.clamp(16.0, 32.0),
              min: 16,
              max: 32,
              divisions: 16,
              activeColor: gold,
              inactiveColor: Colors.white24,
              label: selectedFontSize.round().toString(),
              onChanged: selectFont,
            ),
            Text(
              '${selectedFontSize.round()}',
              style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      const Divider(color: Colors.white12, height: 1),
      settingTile(
        icon: Icons.font_download_outlined,
        title: tr('نوع الخط', 'Font style'),
        subtitle: tr(
          'الخط النسخي - قيد التجهيز',
          'Naskh font - being prepared',
        ),
        onTap: () => comingSoon(tr('نوع الخط', 'Font style')),
      ),
    ]);
  }

  Widget buildLanguage() {
    final currentLanguage =
        Localizations.localeOf(context).languageCode;

    return settingsCard([
      ListTile(
        leading: const Text('🇮🇶', style: TextStyle(fontSize: 25)),
        title: const Text(
          'العربية',
          style: TextStyle(color: Colors.white),
        ),
        trailing: currentLanguage == 'ar'
            ? const Icon(Icons.check_circle, color: gold)
            : null,
        onTap: () => selectLanguage('ar'),
      ),
      const Divider(color: Colors.white12, height: 1),
      ListTile(
        leading: const Text('🇬🇧', style: TextStyle(fontSize: 25)),
        title: const Text(
          'English',
          style: TextStyle(color: Colors.white),
        ),
        trailing: currentLanguage == 'en'
            ? const Icon(Icons.check_circle, color: gold)
            : null,
        onTap: () => selectLanguage('en'),
      ),
    ]);
  }

  Widget buildOtherSettings() {
    return settingsCard([
      settingTile(
        icon: Icons.lock_outline,
        title: tr('الخصوصية والأمان', 'Privacy and security'),
        subtitle: tr(
          'قفل التطبيق وحماية الشاشة',
          'App lock and screen protection',
        ),
        onTap: () => comingSoon(
          tr('الخصوصية والأمان', 'Privacy and security'),
        ),
      ),
      const Divider(color: Colors.white12, height: 1),
      settingTile(
        icon: Icons.notifications_none,
        title: tr('الإشعارات', 'Notifications'),
        subtitle: tr(
          'إعدادات التنبيهات والأصوات',
          'Alerts and sounds settings',
        ),
        onTap: () => comingSoon(
          tr('الإشعارات', 'Notifications'),
        ),
      ),
      const Divider(color: Colors.white12, height: 1),
      settingTile(
        icon: Icons.account_circle_outlined,
        title: tr('الحساب والملف الشخصي', 'Account and profile'),
        onTap: () => comingSoon(
          tr('الحساب والملف الشخصي', 'Account and profile'),
        ),
      ),
      const Divider(color: Colors.white12, height: 1),
      settingTile(
        icon: Icons.storage_outlined,
        title: tr('الملفات ومساحة التخزين', 'Files and storage'),
        onTap: () => comingSoon(
          tr('الملفات ومساحة التخزين', 'Files and storage'),
        ),
      ),
      const Divider(color: Colors.white12, height: 1),
      settingTile(
        icon: Icons.info_outline,
        title: tr('حول التطبيق', 'About'),
        onTap: () {
          showAboutDialog(
            context: context,
            applicationName: 'moon',
            applicationVersion: '1.0.0',
            applicationLegalese: tr(
              'تطبيق moon',
              'moon application',
            ),
          );
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          foregroundColor: gold,
          elevation: 0,
          centerTitle: true,
          title: Text(
            tr('الإعدادات', 'Settings'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(17, 10, 17, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: gold, width: 1.3),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.nightlight_round,
                    color: gold,
                    size: 43,
                  ),
                  SizedBox(height: 9),
                  Text(
                    'moon',
                    style: TextStyle(
                      color: gold,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),

            sectionTitle(
              tr('المظهر', 'Appearance'),
              Icons.palette_outlined,
            ),
            buildAppearance(),

            sectionTitle(
              tr('الألوان', 'Colors'),
              Icons.color_lens_outlined,
            ),
            buildColors(),

            sectionTitle(
              tr('الخط والكتابة', 'Font and text'),
              Icons.text_fields,
            ),
            buildFontSettings(),

            sectionTitle(
              tr('اللغة', 'Language'),
              Icons.language,
            ),
            buildLanguage(),

            sectionTitle(
              tr('الإعدادات العامة', 'General settings'),
              Icons.settings_outlined,
            ),
            buildOtherSettings(),

            const SizedBox(height: 25),
            Center(
              child: Text(
                'moon',
                style: TextStyle(
                  color: selectedColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
