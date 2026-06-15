import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/theme/app_colors.dart';
import '../../data/models/chat_message_model.dart';
import '../cubits/chat_cubit.dart';
import '../cubits/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String otherPartyName;
  final String? otherPartyAvatar;

  const ChatScreen({super.key, required this.otherPartyName, this.otherPartyAvatar});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scroll  = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().init();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<ChatCubit>().sendMessage(text);
    _msgCtrl.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        _buildHeader(context),
        Expanded(
          child: BlocConsumer<ChatCubit, ChatState>(
            listener: (context, state) {
              if (state is ChatLoaded) _scrollToBottom();
            },
            builder: (context, state) {
              if (state is ChatLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
              }
              if (state is ChatError) {
                return Center(
                  child: Text(state.message,
                      style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                );
              }
              if (state is ChatLoaded) {
                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.chat_bubble_outline, color: AppColors.fieldBorder, size: 48),
                      const SizedBox(height: 12),
                      Text('No messages yet',
                          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Start the conversation with ${widget.otherPartyName}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                    ]),
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: state.messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = state.messages[i];
                    final isMe = msg.senderId == context.read<ChatCubit>().currentUserId;
                    final showDate = i == 0 ||
                        !_sameDay(state.messages[i - 1].createdAt, msg.createdAt);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDate) _buildDateSeparator(msg.createdAt),
                        _buildBubble(msg, isMe),
                      ],
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
        _buildInput(),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        _buildAvatar(),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.otherPartyName,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('Post-session chat',
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54)),
        ])),
      ]),
    );
  }

  Widget _buildAvatar() {
    final initials = widget.otherPartyName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final fallback = Container(
      width: 38, height: 38,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.purple, AppColors.navy]),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(initials.isNotEmpty ? initials : '?',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );

    final avatar = widget.otherPartyAvatar;
    if (avatar == null || avatar.isEmpty) return fallback;

    const base = 'https://wakeell.microdesk.tech';
    final url = avatar.startsWith('http') ? avatar : '$base$avatar';

    return ClipOval(
      child: SizedBox(
        width: 38, height: 38,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) =>
              progress == null ? child : fallback,
          errorBuilder: (ctx, err, stack) => fallback,
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: TextField(
              controller: _msgCtrl,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _send,
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.cyan, AppColors.navy]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _buildBubble(ChatMessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe
              ? null
              : Border.all(color: AppColors.fieldBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!isMe) ...[
            Text(msg.senderName,
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.cyan)),
            const SizedBox(height: 2),
          ],
          Text(msg.message,
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  height: 1.4)),
          const SizedBox(height: 4),
          Text(_formatTime(msg.createdAt),
              style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: isMe ? Colors.white38 : AppColors.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(_formatDate(date),
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ]),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
