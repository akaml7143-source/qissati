
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_page.dart';

class StoryPage extends StatefulWidget {
  final Color accentColor;
  final double fontSize;
  final VoidCallback onSettings;

  const StoryPage({
    super.key,
    required this.accentColor,
    required this.fontSize,
    required this.onSettings,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  static const String sessionKey = 'moon_tasbih_session';
  static const String dailyKey = 'moon_tasbih_daily';
  static const String totalKey = 'moon_tasbih_total';
  static const String dateKey = 'moon_tasbih_date';
  static const String drawingKey = 'moon_story_drawing_v1';

  static const int dailyTarget = 1000;

  int sessionCount = 0;
  int dailyCount = 0;
  int totalCount = 0;

  bool loading = true;

  final List<_DrawStroke> drawingStrokes = [];

  Color drawingColor = const Color(0xFFD4AF37);
  double drawingWidth = 4;

  final List<Color> drawingColors = const [
    Color(0xFFD4AF37),
    Colors.white,
    Color(0xFFE57373),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFF1AFCB),
  ];

  Color get accent => widget.accentColor;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get pageBackground =>
      isDark ? Colors.black : const Color(0xFFFFFDF7);

  Color get cardBackground =>
      isDark ? const Color(0xFF151515) : const Color(0xFFF1EEE6);

  Color get textColor =>
      isDark ? Colors.white : Colors.black87;

  Color get secondaryText =>
      isDark ? Colors.white70 : Colors.black54;

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

  String todayKey() {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    loadCounters();
    loadDrawing();
  }

  Future<void> loadCounters() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDate = prefs.getString(dateKey);
    final today = todayKey();

    int savedDaily = prefs.getInt(dailyKey) ?? 0;

    if (savedDate != today) {
      savedDaily = 0;
      await prefs.setInt(dailyKey, 0);
      await prefs.setString(dateKey, today);
    }

    if (!mounted) return;

    setState(() {
      sessionCount = prefs.getInt(sessionKey) ?? 0;
      dailyCount = savedDaily;
      totalCount = prefs.getInt(totalKey) ?? 0;
      loading = false;
    });
  }

  Future<void> saveCounters() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(sessionKey, sessionCount);
    await prefs.setInt(dailyKey, dailyCount);
    await prefs.setInt(totalKey, totalCount);
    await prefs.setString(dateKey, todayKey());
  }

  Future<void> incrementCounter() async {
    if (loading) return;

    final today = todayKey();
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(dateKey);

    if (!mounted) return;

    setState(() {
      if (savedDate != today) {
        dailyCount = 0;
      }

      sessionCount++;
      dailyCount++;
      totalCount++;
    });

    HapticFeedback.lightImpact();
    await saveCounters();
  }

  Future<void> resetSession() async {
    if (loading || sessionCount == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardBackground,
        title: Text(
          'تصفير عداد الجلسة',
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor),
        ),
        content: Text(
          'هل تريد تصفير عداد الجلسة فقط؟',
          textAlign: TextAlign.center,
          style: TextStyle(color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'تصفير',
              style: TextStyle(color: accent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      sessionCount = 0;
    });

    await saveCounters();
  }

  String formatCount(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  void openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          accentColor: widget.accentColor,
          fontSize: widget.fontSize,
        ),
      ),
    );
  }

  Widget buildStoryText() {
    final parts = story.split('طبيب');

    final textStyle = TextStyle(
      color: textColor,
      fontSize: widget.fontSize,
      height: 1.9,
      fontWeight: FontWeight.w500,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: textStyle,
          children: [
            TextSpan(text: parts.first),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: openChat,
                child: Text(
                  'طبيب',
                  style: textStyle,
                ),
              ),
            ),
            TextSpan(text: parts.skip(1).join('طبيب')),
          ],
        ),
      ),
    );
  }

  Widget pearl({double size = 11}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [
            Colors.white,
            Color(0xFFF7EAD4),
            Color(0xFFB99B70),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFE9D5A9),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget floralDecoration() {
    return Icon(
      Icons.local_florist_rounded,
      color: accent.withValues(alpha: 0.8),
      size: 25,
    );
  }

  Widget buildDeviceButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Ink(
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: primary
                      ? [
                          accent,
                          Color.lerp(accent, Colors.black, 0.35)!,
                        ]
                      : [
                          const Color(0xFFE8D9B9),
                          const Color(0xFFC7B48D),
                        ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: accent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 9,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: primary ? Colors.black : const Color(0xFF59452B),
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: primary ? Colors.black : const Color(0xFF59452B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTasbihDevice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF8),
            Color(0xFFE8DCC5),
            Color(0xFFFFFDF8),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: accent,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFEFA),
              Color(0xFFF5EBD9),
              Color(0xFFFFFEFA),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                floralDecoration(),
                pearl(size: 15),
                pearl(size: 11),
                pearl(size: 15),
                floralDecoration(),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              'اللهم صلِّ على محمد وآل محمد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 17),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE9E4D2),
                    Color(0xFFFFFDF0),
                    Color(0xFFD5D0BA),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accent,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'SESSION COUNTER',
                    style: TextStyle(
                      color: Color(0xFF59452B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatCount(sessionCount).padLeft(6, '0'),
                      style: const TextStyle(
                        color: Color(0xFF202719),
                        fontSize: 43,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                buildDeviceButton(
                  label: 'COUNT',
                  icon: Icons.touch_app_rounded,
                  primary: true,
                  onPressed: incrementCounter,
                ),
                buildDeviceButton(
                  label: 'RESET',
                  icon: Icons.restart_alt_rounded,
                  onPressed: resetSession,
                ),
              ],
            ),

            const SizedBox(height: 17),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                floralDecoration(),
                pearl(size: 13),
                pearl(size: 9),
                pearl(size: 13),
                floralDecoration(),
              ],
            ),

            const SizedBox(height: 17),

            Text(
              'التحدي اليومي',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),

            const SizedBox(height: 7),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'هدفك اليوم: 1000',
                  style: TextStyle(color: Color(0xFF59452B)),
                ),
                Text(
                  '${formatCount(dailyCount)} / 1,000',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (dailyCount / dailyTarget).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: const Color(0xFFD8CEB8),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'هل تعلم كم مرة صلّيت على محمد وآل محمد؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF59452B),
                fontSize: 15,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              formatCount(totalCount),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontSize: 29,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),

            const Text(
              'صلاة على محمد وآل محمد',
              style: TextStyle(
                color: Color(0xFF806B50),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تحميل الرسومات المحفوظة.
  Future<void> loadDrawing() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(drawingKey);

      if (saved == null || saved.isEmpty) return;

      final decoded = jsonDecode(saved) as List<dynamic>;

      final strokes = decoded
          .map(
            (item) => _DrawStroke.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        drawingStrokes
          ..clear()
          ..addAll(strokes);
      });
    } catch (_) {
      // لا يتوقف التطبيق إذا تعذر تحميل الرسم.
    }
  }

  // حفظ الرسومات تلقائياً.
  Future<void> saveDrawing() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final encoded = jsonEncode(
        drawingStrokes.map((stroke) => stroke.toJson()).toList(),
      );

      await prefs.setString(drawingKey, encoded);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ الرسم'),
        ),
      );
    }
  }

  void startDrawing(DragStartDetails details) {
    setState(() {
      drawingStrokes.add(
        _DrawStroke(
          points: [details.localPosition],
          color: drawingColor,
          width: drawingWidth,
        ),
      );
    });
  }

  void continueDrawing(DragUpdateDetails details) {
    if (drawingStrokes.isEmpty) return;

    setState(() {
      drawingStrokes.last.points.add(details.localPosition);
    });
  }

  Future<void> finishDrawing(DragEndDetails details) async {
    await saveDrawing();
  }

  Future<void> clearDrawing() async {
    if (drawingStrokes.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardBackground,
        title: Text(
          'مسح لوحة الرسم',
          style: TextStyle(color: accent),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل تريد مسح جميع الرسومات؟',
          style: TextStyle(color: textColor),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'مسح',
              style: TextStyle(color: accent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      drawingStrokes.clear();
    });

    await saveDrawing();
  }

  Widget buildDrawingBoard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.draw_outlined,
                color: accent,
                size: 24,
              ),
              const SizedBox(width: 9),
              Text(
                'لوحة الرسم',
                style: TextStyle(
                  color: accent,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: clearDrawing,
                tooltip: 'مسح الرسم',
                icon: Icon(
                  Icons.delete_outline,
                  color: accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            height: 280,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF080808)
                  : const Color(0xFFFFFEFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accent.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: startDrawing,
              onPanUpdate: continueDrawing,
              onPanEnd: finishDrawing,
              child: CustomPaint(
                painter: _DrawingPainter(drawingStrokes),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'لون القلم',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 13,
            runSpacing: 12,
            children: drawingColors.map((color) {
              final selected =
                  drawingColor.toARGB32() == color.toARGB32();

              return GestureDetector(
                onTap: () {
                  setState(() {
                    drawingColor = color;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? accent : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 18,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                'سُمك القلم',
                style: TextStyle(color: textColor),
              ),
              Expanded(
                child: Slider(
                  value: drawingWidth,
                  min: 2,
                  max: 12,
                  divisions: 10,
                  activeColor: accent,
                  onChanged: (value) {
                    setState(() {
                      drawingWidth = value;
                    });
                  },
                ),
              ),
              Text(
                drawingWidth.toStringAsFixed(0),
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            'رسوماتك محفوظة تلقائياً على جهازك',
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'لكل منا قصة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accent,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          buildStoryText(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        foregroundColor: accent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'moon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.onSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
            children: [
              if (loading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: accent,
                    ),
                  ),
                )
              else
                buildTasbihDevice(),

              const SizedBox(height: 25),

              buildDrawingBoard(),

              const SizedBox(height: 25),

              buildStoryCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// بيانات كل خط مرسوم.
class _DrawStroke {
  final List<Offset> points;
  final Color color;
  final double width;

  _DrawStroke({
    required this.points,
    required this.color,
    required this.width,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((point) {
        return {
          'x': point.dx,
          'y': point.dy,
        };
      }).toList(),
      'color': color.toARGB32(),
      'width': width,
    };
  }

  factory _DrawStroke.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>;

    return _DrawStroke(
      points: rawPoints.map((point) {
        final data = Map<String, dynamic>.from(point as Map);

        return Offset(
          (data['x'] as num).toDouble(),
          (data['y'] as num).toDouble(),
        );
      }).toList(),
      color: Color((json['color'] as num).toInt()),
      width: (json['width'] as num).toDouble(),
    );
  }
}

// رسام اللوحة.
class _DrawingPainter extends CustomPainter {
  final List<_DrawStroke> strokes;

  _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.width / 2,
          Paint()
            ..color = stroke.color
            ..style = PaintingStyle.fill,
        );
        continue;
      }

      final path = Path()
        ..moveTo(
          stroke.points.first.dx,
          stroke.points.first.dy,
        );

      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(
          stroke.points[i].dx,
          stroke.points[i].dy,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return true;
  }
}
