// lib/screens/message_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:makeit/course_page.dart';
import 'package:makeit/profile_page.dart';
import 'package:makeit/search.dart';
import 'package:makeit/student_homepage.dart';
import 'package:makeit/widgets/custom_nav_bar.dart';
import 'package:makeit/services/firestore_service.dart';
import 'package:makeit/services/ai_chat_service.dart';
import 'package:makeit/models/chat_message.dart';
import 'package:makeit/models/notification_model.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final AiChatService _aiChatService = AiChatService();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _sending = false;
  bool _shouldScrollToBottom = false;
  int _unreadCount = 0;
  StreamSubscription<int>? _unreadSub;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CoursePage()),
        );
        break;
      // Already on CoursePage
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => searchPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MessagePage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfilePage()), // Replace with your account page
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _unreadSub =
        _firestoreService.getUnreadNotificationsCountStream().listen((count) {
      if (!mounted) return;
      setState(() => _unreadCount = count);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _unreadSub?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _chatController.clear();
    _shouldScrollToBottom = true;

    try {
      await _firestoreService.addChatMessage(ChatMessage(
        id: '',
        role: 'user',
        text: text,
        createdAt: DateTime.now(),
      ));

      final reply = await _aiChatService.getReply(prompt: text);

      _shouldScrollToBottom = true;
      await _firestoreService.addChatMessage(ChatMessage(
        id: '',
        role: 'assistant',
        text: reply,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      await _firestoreService.addChatMessage(ChatMessage(
        id: '',
        role: 'assistant',
        text: 'Sorry, I ran into an error. Please try again.',
        createdAt: DateTime.now(),
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Page background is white
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar background is white
        elevation: 0, // No shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.black87), // Back arrow icon
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen (Home)
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false, // Title is left-aligned as per image
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0), // Height of the TabBar
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // Allow tabs to scroll if many
              labelColor: Colors.black, // Color of selected tab text
              unselectedLabelColor: Colors.grey, // Color of unselected tab text
              indicatorColor: Color(0xFF47E6FB), // Cyan indicator
              indicatorSize:
                  TabBarIndicatorSize.tab, // Indicator covers the tab
              indicatorWeight: 3.0, // Thickness of the indicator
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
              ),
              tabs: [
                Tab(text: 'AI Chat'),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Notifications'),
                      SizedBox(width: 5),
                      if (_unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _unreadCount > 99 ? '99+' : '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Message Tab Content
          Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _firestoreService.getChatMessagesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('Ask me anything about your courses.'),
                      );
                    }

                    if (_shouldScrollToBottom &&
                        _chatScrollController.hasClients) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_chatScrollController.hasClients) {
                          _chatScrollController.jumpTo(0);
                        }
                        _shouldScrollToBottom = false;
                      });
                    }

                    return ListView.builder(
                      controller: _chatScrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg.role == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(maxWidth: 320),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF47E6FB)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Ask the AI assistant...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sending ? null : _sendMessage,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Notification Tab Content (can be similar structure or different)
          StreamBuilder<List<AppNotification>>(
            stream: _firestoreService.getNotificationsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('No notifications yet.'));
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: items.any((n) => !n.read)
                            ? () async {
                                await _firestoreService
                                    .markAllNotificationsRead();
                              }
                            : null,
                        child: const Text('Mark all read'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final n = items[index];
                        return ListTile(
                          tileColor: n.read ? Colors.white : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight:
                                  n.read ? FontWeight.w500 : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(n.body),
                          trailing: n.read
                              ? null
                              : const Icon(Icons.circle,
                                  size: 10, color: Colors.orange),
                          onTap: () async {
                            if (!n.read) {
                              await _firestoreService
                                  .markNotificationRead(n.id);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
