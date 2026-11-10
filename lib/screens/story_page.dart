
import 'dart:convert';

import 'package:flutter/material.dart';
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
  static const Color gold = Color(0xFFD4AF37);
  static const String drawingKey = 'moon_story_drawing_v1';

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

  final List<List<Offset>> strokes = [];
  List<Offset> currentStroke = [];

  final List<_StoryScene> scenes = const [
    _StoryScene(
      title: 'رحلة القطار',
      icon: Icons.train_rounded,
      secondIcon: Icons.airline_seat_recline_normal,
      description: 'بداية الرحلة داخل القطار',
    ),
    _StoryScene(
      title: 'الأشجار',
      icon: Icons.forest_rounded,
      secondIcon: Icons.park_rounded,
      description: 'الشاب يرى الأشجار للمرة الأولى',
    ),
    _StoryScene(
      title: 'الغيوم',
      icon: Icons.cloud_rounded,
      secondIcon: Icons.wb_sunny_rounded,
      description: 'الغيوم في السماء',
    ),
    _StoryScene(
      title: 'الطبيب',
      icon: Icons.medical_services_rounded,
      secondIcon: Icons.local_hospital_rounded,
      description: 'الحديث عن الطبيب والمستشفى',
    ),
    _StoryScene(
      title: 'عودة البصر',
      icon: Icons.visibility_rounded,
      secondIcon: Icons.favorite_rounded,
      description: 'الحقيقة التي غيّرت نظرة الجميع',
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadDrawing();
  }

  Future<void> loadDrawing() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(drawingKey);

    if (saved == null || !mounted) return;

    try {
      final decoded = jsonDecode(saved) as List;
      final loadedStrokes = decoded.map<List<Offset>>((stroke) {
        return (stroke as List).map<Offset>((point) {
          final values = point as List;
          return Offset(
            (values[0] as num).toDouble(),
            (values[1] as num).toDouble(),
          );
        }).toList();
      }).toList();

      if (!mounted) return;

      setState(() {
        strokes
          ..clear()
          ..addAll(loadedStrokes);
      });
    } catch (_) {
      // تجاهل بيانات الرسم غير الصالحة.
    }
  }

  Future<void> saveDrawing() async {
    final prefs = await SharedPreferences.getInstance();

    final data = strokes.map((stroke) {
      return stroke.map((point) {
        return [point.dx, point.dy];
      }).toList();
    }).toList();

    await prefs.setString(drawingKey, jsonEncode(data));
  }

  void startDrawing(DragStartDetails details, Size size) {
    setState(() {
      currentStroke = [
        Offset(
          (details.localPosition.dx / size.width).clamp(0.0, 1.0),
          (details.localPosition.dy / size.height).clamp(0.0, 1.0),
        ),
      ];
      strokes.add(currentStroke);
    });
  }

  void continueDrawing(DragUpdateDetails details, Size size) {
    setState(() {
      currentStroke.add(
        Offset(
          (details.localPosition.dx / size.width).clamp(0.0, 1.0),
          (details.localPosition.dy / size.height).clamp(0.0, 1.0),
        ),
      );
    });
    saveDrawing();
  }

  void finishDrawing() {
    saveDrawing();
    currentStroke = [];
  }

  Future<void> clearDrawing() async {
    setState(() {
      strokes.clear();
      currentStroke.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(drawingKey);
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
      color: Colors.white,
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
                child: Text('طبيب', style: textStyle),
              ),
            ),
            TextSpan(
              text: parts.skip(1).join('طبيب'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScene(_StoryScene scene, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        border: Border.all(color: gold, width: 1.4),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.10),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: Text(
              'المشهد ${index + 1} - ${scene.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: gold,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 190,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF080B12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: gold.withValues(alpha: 0.55),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 15,
                  right: 20,
                  child: Icon(
                    Icons.star,
                    color: gold.withValues(alpha: 0.5),
                    size: 18,
                  ),
                ),
                Positioned(
                  top: 35,
                  left: 35,
                  child: Icon(
                    Icons.star,
                    color: gold.withValues(alpha: 0.35),
                    size: 13,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      scene.icon,
                      color: gold,
                      size: 85,
                    ),
                    const SizedBox(width: 22),
                    Icon(
                      scene.secondIcon,
                      color: Colors.white70,
                      size: 65,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 12,
                  child: Text(
                    scene.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(17, 18, 17, 20),
            child: buildStoryText(),
          ),
        ],
      ),
    );
  }

  Widget buildDrawingBoard() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 25),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        border: Border.all(color: gold, width: 1.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            'مساحة الرسم',
            style: TextStyle(
              color: gold,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'ارسم بإصبعك واحتفظ برسوماتك',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final boardSize = Size(
                constraints.maxWidth,
                300,
              );

              return GestureDetector(
                onPanStart: (details) {
                  startDrawing(details, boardSize);
                },
                onPanUpdate: (details) {
                  continueDrawing(details, boardSize);
                },
                onPanEnd: (_) {
                  finishDrawing();
                },
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: gold.withValues(alpha: 0.6),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomPaint(
                    painter: _DrawingPainter(strokes: strokes),
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: strokes.isEmpty ? null : clearDrawing,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('مسح الرسم'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: gold,
                    side: const BorderSide(color: gold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: gold,
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
            padding: const EdgeInsets.fromLTRB(17, 15, 17, 30),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: gold, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'لكل منا قصة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: gold,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              for (int i = 0; i < scenes.length; i++)
                buildScene(scenes[i], i),
              buildDrawingBoard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryScene {
  final String title;
  final IconData icon;
  final IconData secondIcon;
  final String description;

  const _StoryScene({
    required this.title,
    required this.icon,
    required this.secondIcon,
    required this.description,
  });
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _DrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      if (stroke.length == 1) {
        canvas.drawCircle(
          Offset(
            stroke.first.dx * size.width,
            stroke.first.dy * size.height,
          ),
          2,
          paint,
        );
        continue;
      }

      final path = Path()
        ..moveTo(
          stroke.first.dx * size.width,
          stroke.first.dy * size.height,
        );

      for (final point in stroke.skip(1)) {
        path.lineTo(
          point.dx * size.width,
          point.dy * size.height,
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
