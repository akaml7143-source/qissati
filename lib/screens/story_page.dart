
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

class StoryPage extends StatelessWidget {
  final Color accentColor;
  final double fontSize;
  final VoidCallback onSettings;

  const StoryPage({
    super.key,
    required this.accentColor,
    required this.fontSize,
    required this.onSettings,
  });

  static const Color turquoise = Color(0xFFBDECE8);

  static const String story = '''
خلال إحدى الرحلات في القطار، صاح شاب في العشرين من العمر فجأة:

"أبي انظر إلى الأشجار! إنها تسير إلى الوراء!"

وابتسم حينها الأب لابنه في عطف في حين راح بقيّة الركاب ينظرون إلى الشاب بعين الشفقة. وما هي إلّا لحظات حتى صاح الشاب مجدّدًا:

"أبي! أبي... انظر إلى الغيوم في السماء، إنّها تلحقُ بنا أيضًا!"

ابتسم الأب من جديد، وفي حينها اقترب منه أحد الركاب وقال له:

"لماذا لا تعرض ابنك على طبيب جيّد؟"

وأجاب الأب:

"لقد فعلت، في الواقع نحن عائدان من المستشفى، لقد كان ابني كفيفًا منذ الولادة، واليوم فقط استعاد بصره!"

العبرة المستفادة من هذه القصة:
لكلّ شخصٍ منّا قصة، فلا تحكم على الآخرين قبل أن تعرفهم جيّدًا...قد تدهشك الحقيقة عنهم.
''';

  void openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          accentColor: accentColor,
          fontSize: fontSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final parts = story.split('طبيب');

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      height: 1.9,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      backgroundColor: turquoise,
      appBar: AppBar(
        backgroundColor: turquoise,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'MY STORY',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: isArabic ? 'الإعدادات' : 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection:
              isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(23, 22, 23, 35),
            children: [
              Text(
                isArabic ? 'هذه القصة' : 'THIS STORY',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 27),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: parts[0],
                      style: textStyle,
                    ),
                    TextSpan(
                      text: 'طبيب',
                      style: textStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => openChat(context),
                    ),
                    TextSpan(
                      text: parts.sublist(1).join('طبيب'),
                      style: textStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'لكل شخص قصة...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

