
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'text': 'مرحباً بك في moon 🌙',
      'mine': false,
      'time': 'الآن',
      'edited': false,
      'reply': null,
    },
    {
      'text': 'هذه مساحة خاصة للمراسلة بيننا.',
      'mine': false,
      'time': 'الآن',
      'edited': false,
      'reply': null,
    },
  ];

  final Set<int> selectedMessages = {};

  String? replyText;

  bool get selectionMode => selectedMessages.isNotEmpty;

  bool get isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get accent => widget.accentColor;

  Color get background =>
      isDark ? Colors.black : const Color(0xFFFFFDF7);

  Color get surface =>
      isDark ? const Color(0xFF171717) : const Color(0xFFF0ECE5);

  Color get secondarySurface =>
      isDark ? const Color(0xFF242424) : const Color(0xFFE7E0D5);

  Color get primaryText =>
      isDark ? Colors.white : Colors.black87;

  Color get secondaryText =>
      isDark ? Colors.white60 : Colors.black54;

  Color get myBubble =>
      Color.lerp(background, accent, isDark ? 0.25 : 0.17)!;

  Color get selectedBubble =>
      Color.lerp(background, accent, 0.42)!;

  String tr(String ar, String en) => isArabic ? ar : en;

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: secondarySurface,
      ),
    );
  }

  void showNotReady(String feature) {
    showMessage(
      tr(
        '$feature ستتوفر بعد ربط خادم المراسلة.',
        '$feature will be available after connecting the messaging server.',
      ),
    );
  }

  void scrollToBottom() {
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

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'text': text,
        'mine': true,
        'time': 'الآن',
        'edited': false,
        'reply': replyText,
      });

      replyText = null;
    });

    messageController.clear();
    scrollToBottom();
  }

  Future<void> editMessage(int index) async {
    if (index < 0 || index >= messages.length) return;

    final controller = TextEditingController(
      text: messages[index]['text'] as String,
    );

    final edited = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          title: Text(
            tr('تعديل الرسالة', 'Edit message'),
            style: TextStyle(color: accent),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 5,
            style: TextStyle(color: primaryText),
            decoration: InputDecoration(
              hintText: tr('اكتب التعديل...', 'Edit text...'),
              hintStyle: TextStyle(color: secondaryText),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: accent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: accent,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                tr('إلغاء', 'Cancel'),
                style: TextStyle(color: secondaryText),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: Text(
                tr('حفظ', 'Save'),
                style: TextStyle(color: accent),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (edited == null || edited.isEmpty || !mounted) return;
    if (index >= messages.length) return;

    setState(() {
      messages[index]['text'] = edited;
      messages[index]['edited'] = true;
    });
  }

  Future<bool> confirmDelete({
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: surface,
        title: Text(
          title,
          style: TextStyle(color: accent),
        ),
        content: Text(
          content,
          style: TextStyle(color: primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              tr('إلغاء', 'Cancel'),
              style: TextStyle(color: secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              tr('حذف', 'Delete'),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> deleteMessage(int index) async {
    if (index < 0 || index >= messages.length) return;

    final confirmed = await confirmDelete(
      title: tr('حذف الرسالة', 'Delete message'),
      content: tr(
        'هل تريد حذف هذه الرسالة من هذه المحادثة؟',
        'Delete this message from this chat?',
      ),
    );

    if (!confirmed || !mounted) return;
    if (index >= messages.length) return;

    setState(() {
      messages.removeAt(index);
      selectedMessages.clear();
    });
  }

  Future<void> deleteSelected() async {
    if (selectedMessages.isEmpty) return;

    final confirmed = await confirmDelete(
      title: tr('حذف الرسائل', 'Delete messages'),
      content: tr(
        'هل تريد حذف الرسائل المحددة من هذه المحادثة؟',
        'Delete the selected messages from this chat?',
      ),
    );

    if (!confirmed || !mounted) return;

    setState(() {
      final indexes = selectedMessages.toList()
        ..sort((a, b) => b.compareTo(a));

      for (final index in indexes) {
        if (index >= 0 && index < messages.length) {
          messages.removeAt(index);
        }
      }

      selectedMessages.clear();
    });
  }

  void copyMessage(int index) {
    if (index < 0 || index >= messages.length) return;

    Clipboard.setData(
      ClipboardData(
        text: messages[index]['text'] as String,
      ),
    );

    showMessage(tr('تم نسخ الرسالة', 'Message copied'));
  }

  void replyToMessage(int index) {
    if (index < 0 || index >= messages.length) return;

    setState(() {
      replyText = messages[index]['text'] as String;
      selectedMessages.clear();
    });
  }

  void forwardMessage(int index) {
    if (index < 0 || index >= messages.length) return;

    final text = messages[index]['text'] as String;

    setState(() {
      messages.add({
        'text': '↪ $text',
        'mine': true,
        'time': 'الآن',
        'edited': false,
        'reply': null,
        'forwarded': true,
      });
    });

    scrollToBottom();

    showMessage(
      tr(
        'أضيفت نسخة محلية من الرسالة إلى المحادثة.',
        'A local copy was added to the conversation.',
      ),
    );
  }

  void toggleSelection(int index) {
    if (index < 0 || index >= messages.length) return;

    setState(() {
      if (selectedMessages.contains(index)) {
        selectedMessages.remove(index);
      } else {
        selectedMessages.add(index);
      }
    });
  }

  Widget actionTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    final itemColor = color ?? primaryText;

    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: TextStyle(color: itemColor),
      ),
      onTap: onTap,
    );
  }

  void showMessageOptions(int index) {
    if (index < 0 || index >= messages.length) return;

    final message = messages[index];
    final mine = message['mine'] as bool;

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: secondaryText,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              const SizedBox(height: 10),

              actionTile(
                tr('رد', 'Reply'),
                Icons.reply,
                () {
                  Navigator.pop(sheetContext);
                  replyToMessage(index);
                },
              ),

              actionTile(
                tr('نسخ', 'Copy'),
                Icons.copy,
                () {
                  Navigator.pop(sheetContext);
                  copyMessage(index);
                },
              ),

              actionTile(
                tr('إعادة توجيه', 'Forward'),
                Icons.forward,
                () {
                  Navigator.pop(sheetContext);
                  forwardMessage(index);
                },
              ),

              actionTile(
                tr('تحديد', 'Select'),
                Icons.check_circle_outline,
                () {
                  Navigator.pop(sheetContext);
                  toggleSelection(index);
                },
              ),

              if (mine)
                actionTile(
                  tr('تعديل', 'Edit'),
                  Icons.edit_outlined,
                  () {
                    Navigator.pop(sheetContext);
                    editMessage(index);
                  },
                  color: accent,
                ),

              if (mine)
                actionTile(
                  tr('حذف', 'Delete'),
                  Icons.delete_outline,
                  () {
                    Navigator.pop(sheetContext);
                    deleteMessage(index);
                  },
                  color: Colors.redAccent,
                ),

              actionTile(
                tr('حذف لدى الطرفين', 'Delete for both'),
                Icons.delete_sweep_outlined,
                () {
                  Navigator.pop(sheetContext);
                  showNotReady(
                    tr('الحذف لدى الطرفين', 'Delete for both'),
                  );
                },
                color: Colors.redAccent,
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget buildMessageBubble(int index) {
    final message = messages[index];
    final mine = message['mine'] as bool;
    final selected = selectedMessages.contains(index);
    final text = message['text'] as String;
    final reply = message['reply'] as String?;

    final bubbleColor = selected
        ? selectedBubble
        : mine
            ? myBubble
            : surface;

    return GestureDetector(
      onLongPress: () {
        if (!selectionMode) {
          showMessageOptions(index);
        } else {
          toggleSelection(index);
        }
      },
      onTap: selectionMode ? () => toggleSelection(index) : null,
      child: Align(
        alignment: mine
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            border: Border.all(
              color: selected
                  ? accent
                  : mine
                      ? accent
                      : secondaryText.withValues(alpha: 0.3),
              width: selected ? 2 : 0.8,
            ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(17),
              topRight: const Radius.circular(17),
              bottomLeft: Radius.circular(mine ? 17 : 4),
              bottomRight: Radius.circular(mine ? 4 : 17),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (reply != null && reply.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: secondarySurface,
                    border: Border(
                      right: BorderSide(
                        color: accent,
                        width: 3,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    reply,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  text,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: widget.fontSize,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message['edited'] == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        tr('معدّلة', 'edited'),
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                        ),
                      ),
                    ),

                  Text(
                    message['time'] as String,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 10,
                    ),
                  ),

                  if (mine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all,
                      color: accent,
                      size: 15,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReplyPreview() {
    if (replyText == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          right: BorderSide(
            color: accent,
            width: 3,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${tr('الرد على:', 'Replying to:')} $replyText',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: secondaryText),
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                replyText = null;
              });
            },
            icon: Icon(
              Icons.close,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildComposer() {
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildReplyPreview(),

            Row(
              children: [
                IconButton(
                  onPressed: () => showNotReady(
                    tr('المرفقات', 'Attachments'),
                  ),
                  icon: Icon(
                    Icons.attach_file,
                    color: accent,
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: 5,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: widget.fontSize,
                    ),
                    decoration: InputDecoration(
                      hintText: tr(
                        'اكتب رسالتك...',
                        'Write a message...',
                      ),
                      hintStyle: TextStyle(color: secondaryText),
                      filled: true,
                      fillColor: surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: accent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: secondaryText.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                Material(
                  color: accent,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: Icon(
                      Icons.send_rounded,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          foregroundColor: accent,
          elevation: 0,

          leading: selectionMode
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      selectedMessages.clear();
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : null,

          title: selectionMode
              ? Text(
                  '${selectedMessages.length}',
                  style: TextStyle(color: accent),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'moon',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    Text(
                      tr('مراسلة خاصة', 'Private chat'),
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),

          actions: selectionMode
              ? [
                  IconButton(
                    onPressed: deleteSelected,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    tooltip: tr(
                      'حذف المحدد',
                      'Delete selected',
                    ),
                  ),
                ]
              : [
                  IconButton(
                    onPressed: () => showNotReady(
                      tr('المكالمة الصوتية', 'Voice calls'),
                    ),
                    icon: const Icon(Icons.call_outlined),
                  ),
                  IconButton(
                    onPressed: () => showNotReady(
                      tr('مكالمة الفيديو', 'Video calls'),
                    ),
                    icon: const Icon(Icons.videocam_outlined),
                  ),
                ],
        ),

        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return buildMessageBubble(index);
                },
              ),
            ),

            if (!selectionMode) buildComposer(),
          ],
        ),
      ),
    );
  }
}
