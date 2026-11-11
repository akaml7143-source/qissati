
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

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    selectedTheme = widget.themeMode;
    selectedColor = widget.accentColor;
    selectedFontSize = widget.fontSize;
  }

  bool get isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get accent => selectedColor;

  Color get background =>
      isDark ? Colors.black : const Color(0xFFFFFDF7);

  Color get cardColor =>
      isDark ? const Color(0xFF111111) : const Color(0xFFF1EEE6);

  Color get primaryText =>
      isDark ? Colors.white : Colors.black87;

  Color get secondaryText =>
      isDark ? Colors.white70 : Colors.black54;

  Color get dividerColor =>
      accent.withValues(alpha: 0.22);

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
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          title,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          tr(
            'هذا القسم سنفعّله في المرحلة القادمة بعد تجهيز وظيفته.',
            'This section will be enabled in a future development stage.',
          ),
          style: TextStyle(color: secondaryText),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              tr('حسناً', 'OK'),
              style: TextStyle(color: accent),
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
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: accent,
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
          color: accent.withValues(alpha: 0.35),
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
      leading: Icon(icon, color: accent),
      title: Text(
        title,
        style: TextStyle(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(color: secondaryText),
            ),
      trailing: trailing ??
          Icon(
            isArabic
                ? Icons.arrow_back_ios
                : Icons.arrow_forward_ios,
            color: secondaryText,
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
        activeColor: accent,
        secondary: Icon(Icons.dark_mode, color: accent),
        title: Text(
          tr('الوضع الليلي', 'Dark mode'),
          style: TextStyle(color: primaryText),
        ),
        onChanged: (value) {
          if (value != null) selectTheme(value);
        },
      ),
      Divider(color: dividerColor, height: 1),
      RadioListTile<ThemeMode>(
        value: ThemeMode.light,
        groupValue: selectedTheme,
        activeColor: accent,
        secondary: Icon(Icons.light_mode, color: accent),
        title: Text(
          tr('الوضع النهاري', 'Light mode'),
          style: TextStyle(color: primaryText),
        ),
        onChanged: (value) {
          if (value != null) selectTheme(value);
        },
      ),
    ]);
  }

  Widget buildColors() {
    final colorNames = isArabic
        ? ['ذهبي', 'وردي', 'فيروزي', 'كحلي', 'أخضر', 'عنابي']
        : ['Gold', 'Pink', 'Teal', 'Indigo', 'Green', 'Maroon'];

    return settingsCard([
      Padding(
        padding: const EdgeInsets.all(17),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 18,
          children: List.generate(colors.length, (index) {
            final color = colors[index];

            final selected =
                color.toARGB32() == selectedColor.toARGB32();

            return GestureDetector(
              onTap: () => selectColor(color),
              child: SizedBox(
                width: 65,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? primaryText
                              : Colors.transparent,
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
                    const SizedBox(height: 6),
                    Text(
                      colorNames[index],
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
              style: TextStyle(
                color: secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              tr('لكل منا قصة جميلة', 'Everyone has a story'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryText,
                fontSize: selectedFontSize,
              ),
            ),
            Slider(
              value: selectedFontSize.clamp(16.0, 32.0),
              min: 16,
              max: 32,
              divisions: 16,
              activeColor: accent,
              inactiveColor: secondaryText.withValues(alpha: 0.25),
              label: selectedFontSize.round().toString(),
              onChanged: selectFont,
            ),
            Text(
              '${selectedFontSize.round()}',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      Divider(color: dividerColor, height: 1),
      settingTile(
        icon: Icons.font_download_outlined,
        title: tr('نوع الخط', 'Font style'),
        subtitle: tr(
          'الخط النسخي - قيد التجهيز',
          'Naskh font - being prepared',
        ),
        onTap: () => comingSoon(
          tr('نوع الخط', 'Font style'),
        ),
      ),
    ]);
  }

  Widget buildLanguage() {
    final currentLanguage =
        Localizations.localeOf(context).languageCode;

    return settingsCard([
      ListTile(
        leading: const Text('🇮🇶', style: TextStyle(fontSize: 25)),
        title: Text(
          'العربية',
          style: TextStyle(color: primaryText),
        ),
        trailing: currentLanguage == 'ar'
            ? Icon(Icons.check_circle, color: accent)
            : null,
        onTap: () => selectLanguage('ar'),
      ),
      Divider(color: dividerColor, height: 1),
      ListTile(
        leading: const Text('🇬🇧', style: TextStyle(fontSize: 25)),
        title: Text(
          'English',
          style: TextStyle(color: primaryText),
        ),
        trailing: currentLanguage == 'en'
            ? Icon(Icons.check_circle, color: accent)
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
      Divider(color: dividerColor, height: 1),
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
      Divider(color: dividerColor, height: 1),
      settingTile(
        icon: Icons.account_circle_outlined,
        title: tr('الحساب والملف الشخصي', 'Account and profile'),
        onTap: () => comingSoon(
          tr('الحساب والملف الشخصي', 'Account and profile'),
        ),
      ),
      Divider(color: dividerColor, height: 1),
      settingTile(
        icon: Icons.storage_outlined,
        title: tr('الملفات ومساحة التخزين', 'Files and storage'),
        onTap: () => comingSoon(
          tr('الملفات ومساحة التخزين', 'Files and storage'),
        ),
      ),
      Divider(color: dividerColor, height: 1),
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
          foregroundColor: accent,
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
                border: Border.all(
                  color: accent,
                  width: 1.3,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.nightlight_round,
                    color: accent,
                    size: 43,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'moon',
                    style: TextStyle(
                      color: accent,
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
                  color: accent,
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
