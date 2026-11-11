
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryPage extends StatefulWidget {
  final Color accentColor;
  final double fontSize;
  final VoidCallback onSettings;
  final VoidCallback onOpenChat;

  const StoryPage({
    super.key,
    required this.accentColor,
    required this.fontSize,
    required this.onSettings,
    required this.onOpenChat,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _DrawStroke {
  final List<Offset> points;
  final Color color;
  final double width;

  _DrawStroke({
    required this.points,
    required this.color,
    required this.width,
  });

  Map<String, dynamic> toJson() => {
        'points': points
            .map((p) => {'x': p.dx, 'y': p.dy})
            .toList(),
        'color': color.value,
        'width': width,
      };

  factory _DrawStroke.fromJson(Map<String, dynamic> json) {
    return _DrawStroke(
      points: (json['points'] as List)
          .map((p) => Offset(
                (p['x'] as num).toDouble(),
                (p['y'] as num).toDouble(),
              ))
          .toList(),
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
    );
  }
}

class _StoryPageState extends State<StoryPage> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFF101010);

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

  int sessionCount = 0;
  int dailyCount = 0;
  int totalCount = 0;

  final int dailyTarget = 1000;

  List<_DrawStroke> strokes = [];
  _DrawStroke? currentStroke;

  Color drawingColor = Colors.white;
  double drawingWidth = 4;

  final List<Color> drawingColors = [
    Colors.white,
    gold,
    Colors.redAccent,
    Colors.lightBlueAccent,
    Colors.greenAccent,
    Colors.pinkAccent,
  ];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  String get today {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    int savedDaily = prefs.getInt('moon_tasbih_daily') ?? 0;
    final savedDate = prefs.getString('moon_tasbih_date') ?? '';

    if (savedDate != today) {
      savedDaily = 0;
      await prefs.setInt('moon_tasbih_daily', 0);
      await prefs.setString('moon_tasbih_date', today);
    }

    final drawingData = prefs.getString('moon_story_drawing_v1');

    List<_DrawStroke> loadedStrokes = [];

    if (drawingData != null) {
      try {
        final decoded = jsonDecode(drawingData) as List;
        loadedStrokes = decoded
            .map((item) => _DrawStroke.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
      } catch (_) {
        loadedStrokes = [];
      }
    }

    if (!mounted) return;

    setState(() {
      sessionCount = prefs.getInt('moon_tasbih_session') ?? 0;
      dailyCount = savedDaily;
      totalCount = prefs.getInt('moon_tasbih_total') ?? 0;
      strokes = loadedStrokes;
      loading = false;
    });
  }

  Future<void> saveCounters() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('moon_tasbih_session', sessionCount);
    await prefs.setInt('moon_tasbih_daily', dailyCount);
    await prefs.setInt('moon_tasbih_total', totalCount);
    await prefs.setString('moon_tasbih_date', today);
  }

  Future<void> incrementCounter() async {
    if (loading) return;

    setState(() {
      sessionCount++;
      dailyCount++;
      totalCount++;
    });

    HapticFeedback.selectionClick();
    await saveCounters();
  }

  Future<void> resetSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF242424),
        title: const Text(
          'تصفير العدّ الحالي',
          textAlign: TextAlign.right,
          style: TextStyle(color: gold),
        ),
        content: const Text(
          'هل تريد تصفير عدّ الجلسة الحالية فقط؟',
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تصفير',
              style: TextStyle(color: gold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => sessionCount = 0);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('moon_tasbih_session', 0);
    }
  }

  Future<void> saveDrawing() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(strokes.map((s) => s.toJson()).toList());
    await prefs.setString('moon_story_drawing_v1', data);
  }

  Future<void> clearDrawing() async {
    if (strokes.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF242424),
        title: const Text(
          'مسح الرسم',
          textAlign: TextAlign.right,
          style: TextStyle(color: gold),
        ),
        content: const Text(
          'هل تريد مسح جميع الرسومات؟',
          textAlign: TextAlign.right,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'مسح',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        strokes.clear();
        currentStroke = null;
      });
      await saveDrawing();
    }
  }

  void openChat() {
    widget.onOpenChat();
  }

  String formatCount(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: gold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 9),
        Icon(icon, color: widget.accentColor),
      ],
    );
  }

  Widget counterStat(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: 0.45),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: gold, size: 21),
            const SizedBox(height: 6),
            Text(
              formatCount(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTasbih() {
    final progress = (dailyCount / dailyTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF292319),
            Color(0xFF111111),
            Color(0xFF292319),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: widget.accentColor,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.15),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'اللهم صلِّ على محمد وآل محمد',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF18251F),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: gold.withValues(alpha: 0.7),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'العدد الحالي',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  formatCount(sessionCount),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: resetSession,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تصفير الجلسة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: gold),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: incrementCounter,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    'تسبيح',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              counterStat('عدّ اليوم', dailyCount, Icons.today),
              const SizedBox(width: 8),
              counterStat('المجموع الكلي', totalCount, Icons.all_inclusive),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(color: gold),
              ),
              const Text(
                'الهدف اليومي: 1000',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(widget.accentColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dailyCount >= dailyTarget
                ? 'أحسنت! أتممت هدفك اليومي'
                : 'باقي ${formatCount(dailyTarget - dailyCount)} لإكمال الهدف',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDrawingBoard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: clearDrawing,
                tooltip: 'مسح الرسم',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
              ),
              const Text(
                'سبورة الرسم',
                style: TextStyle(
                  color: gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: saveDrawing,
                tooltip: 'حفظ الرسم',
                icon: const Icon(
                  Icons.save_outlined,
                  color: gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 270,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF080808),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final point = box.globalToLocal(details.globalPosition);

                    setState(() {
                      currentStroke = _DrawStroke(
                        points: [point],
                        color: drawingColor,
                        width: drawingWidth,
                      );
                      strokes.add(currentStroke!);
                    });
                  },
                  onPanUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final point = box.globalToLocal(details.globalPosition);

                    setState(() {
                      currentStroke?.points.add(point);
                    });
                  },
                  onPanEnd: (_) async {
                    currentStroke = null;
                    await saveDrawing();
                  },
                  child: CustomPaint(
                    size: Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                    painter: _DrawingPainter(strokes),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'لون القلم',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 10),
              ...drawingColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => drawingColor = color),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: drawingColor == color ? gold : Colors.white38,
                        width: drawingColor == color ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: drawingWidth,
                  min: 2,
                  max: 12,
                  activeColor: widget.accentColor,
                  onChanged: (value) {
                    setState(() => drawingWidth = value);
                  },
                ),
              ),
              const Text(
                'حجم القلم',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Text(
            'ارسم بإصبعك داخل السبورة، وسيُحفظ الرسم تلقائياً.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildStory() {
    final storyTextStyle = TextStyle(
      color: Colors.white,
      fontSize: widget.fontSize,
      height: 1.9,
    );

    final parts = story.split('طبيب');
    final spans = <InlineSpan>[];

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));

      if (i < parts.length - 1) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: openChat,
              child: Text(
                'طبيب',
                style: storyTextStyle,
              ),
            ),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'لكل منا قصة',
            style: TextStyle(
              color: gold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            text: TextSpan(
              style: storyTextStyle,
              children: spans,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: gold,
        title: const Text(
          'moon',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: widget.onSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: gold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildTasbih(),
                  const SizedBox(height: 25),
                  sectionTitle('سبورة الرسم', Icons.draw_outlined),
                  const SizedBox(height: 12),
                  buildDrawingBoard(),
                  const SizedBox(height: 25),
                  sectionTitle('لكل منا قصة', Icons.menu_book),
                  const SizedBox(height: 12),
                  buildStory(),
                  const SizedBox(height: 25),
                ],
              ),
            ),
    );
  }
}

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
          paint..style = PaintingStyle.fill,
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
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
