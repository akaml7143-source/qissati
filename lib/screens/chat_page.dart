
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final Color accentColor;
  final double fontSize;

  const ChatPage({
    super.key,
    required this.accentColor,
    required this.fontSize,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'text': 'مرحباً بك في قصتي 🌸',
      'mine': false,
      'time': 'الآن',
    },
    {
      'text': 'هذه مساحة خاصة للمراسلة بيننا.',
      'mine': false,
      'time': 'الآن',
    },
  ];

  void showNotReady(String feature) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? '$feature ستتوفر بعد ربط الخادم.'
              : '$feature will be available after server connection.',
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'text': text,
        'mine': true,
        'time': 'الآن',
      });
    });

    messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final pink = const Color(0xFFF1AFCB);

    final background = Theme.of(context).brightness ==
            Brightness.dark
        ? const Color(0xFF211820)
        : const Color(0xFFFFF4F8);

    return Directionality(
      textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: background,

        appBar: AppBar(
          backgroundColor: pink,
          foregroundColor: Colors.black,
          elevation: 2,

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'قصتي' : 'MY STORY',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              Text(
                isArabic
                    ? 'مراسلة خاصة'
                    : 'Private chat',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          actions: [
            IconButton(
              onPressed: () => showNotReady(
                isArabic ? 'المكالمة الصوتية' : 'Voice calls',
              ),
              icon: const Icon(Icons.call_outlined),
              tooltip: isArabic ? 'اتصال صوتي' : 'Voice call',
            ),
            IconButton(
              onPressed: () => showNotReady(
                isArabic ? 'مكالمة الفيديو' : 'Video calls',
              ),
              icon: const Icon(Icons.videocam_outlined),
              tooltip: isArabic ? 'اتصال فيديو' : 'Video call',
            ),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final mine = message['mine'] as bool;

                  return Align(
                    alignment: mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,

                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.78,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: mine
                            ? pink
                            : Theme.of(context).brightness ==
                                    Brightness.dark
                                ? const Color(0xFF3A3038)
                                : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(
                            mine ? 18 : 4,
                          ),
                          bottomRight: Radius.circular(
                            mine ? 4 : 18,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Text(
                            message['text'] as String,
                            style: TextStyle(
                              color: mine
                                  ? Colors.black
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                              fontSize: widget.fontSize,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message['time'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: mine
                                  ? Colors.black54
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(
                10, 10, 10, 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness ==
                        Brightness.dark
                    ? const Color(0xFF30242D)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),

              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => showNotReady(
                        isArabic ? 'إرسال الملفات' : 'Attachments',
                      ),
                      icon: const Icon(
                        Icons.attach_file,
                        color: Color(0xFFD875A5),
                      ),
                    ),

                    Expanded(
                      child: TextField(
                        controller: messageController,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: isArabic
                              ? 'اكتب رسالتك...'
                              : 'Write a message...',
                          filled: true,
                          fillColor: pink.withOpacity(0.18),
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Material(
                      color: pink,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: sendMessage,
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.black,
                        ),
                        tooltip: isArabic ? 'إرسال' : 'Send',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

