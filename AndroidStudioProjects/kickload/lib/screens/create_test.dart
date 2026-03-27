import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class TestHistoryItem {
  final String fileName;
  final String createdAt;
  TestHistoryItem({required this.fileName, required this.createdAt});
}

// ─────────────────────────────────────────────
//  THEME CONSTANTS
// ─────────────────────────────────────────────
class KickLoadColors {
  static const background = AppColors.bg;
  static const cardBg = AppColors.card;
  static const primary = AppColors.blue;
  static const primaryLight = Color(0xFF12263F);
  static const textDark = AppColors.textPrimary;
  static const textMuted = AppColors.textSecondary;
  static const border = AppColors.cardBorder;
  static const inputBorder = AppColors.blue;
  static const historyBg = Color(0xFF111827);
}

// ─────────────────────────────────────────────
//  CREATE TEST SCREEN
// ─────────────────────────────────────────────
class CreateTestScreen extends StatefulWidget {
  const CreateTestScreen({super.key});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _searchQuery = '';

  final List<TestHistoryItem> _history = [
    TestHistoryItem(
        fileName: 'test_plan_23-03-2026_08-07-45.jmx',
        createdAt: 'Created: 23/03/2026, 13:37:46'),
    TestHistoryItem(
        fileName: 'demo_load_test_advanced 1_23-03-2026_07-57-41.jmx',
        createdAt: 'Created: 23/03/2026, 13:27:42'),
    TestHistoryItem(
        fileName: 'test_plan_20-03-2026_09-48-15.jmx',
        createdAt: 'Created: 20/03/2026, 11:22:10'),
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'content':
          '👋 Welcome to KickLoad!\n\nI help you generate test plans for load and performance testing — just describe your test in plain English!\n\n💡 You can also type:\n• \'help\' — for full instructions & test format\n• \'upload csv\' — to learn how CSV data works with examples\n• \'upload jmx\' — to reuse or fix a JMeter test plan\n• \'clear\' or \'reset\' — to restart the chat anytime',
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<TestHistoryItem> get _filteredHistory {
    if (_searchQuery.isEmpty) return _history;
    return _history
        .where((item) =>
            item.fileName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _sendMessage() {
    final text = _promptController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _promptController.clear();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content':
              'Generating your test plan for: "$text"\n\nPlease wait while I create the JMX file...',
        });
        _isLoading = false;
      });
    });
  }

  // ── WIDGETS ──────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Test Plan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: KickLoadColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Unlocking Insights, Enhancing Precision!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: KickLoadColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildChatCard() {
    return Container(
      decoration: BoxDecoration(
        color: KickLoadColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          const Divider(height: 1, color: KickLoadColors.border),
          _buildAssistantLabel(),
          _buildMessageList(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.chat_bubble_outline,
              color: KickLoadColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            'KickLoad Test Generator',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: KickLoadColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.smart_toy_outlined,
              size: 14, color: KickLoadColors.textMuted),
          const SizedBox(width: 4),
          Text(
            'Assistant',
            style: TextStyle(
              fontSize: 12,
              color: KickLoadColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ..._messages.map((msg) => _buildMessageBubble(msg)),
          if (_isLoading) _buildLoadingBubble(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isAssistant = msg['role'] == 'assistant';
    return Align(
      alignment:
          isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: isAssistant
              ? KickLoadColors.primaryLight
              : KickLoadColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msg['content'] ?? '',
          style: TextStyle(
            fontSize: 13.5,
            color: isAssistant ? KickLoadColors.textDark : Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: KickLoadColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: KickLoadColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Generating...',
              style: TextStyle(
                  fontSize: 13, color: KickLoadColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: KickLoadColors.inputBorder, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your prompt or upload a JMX/CSV/Excel file...',
                hintStyle: TextStyle(
                    color: KickLoadColors.textMuted, fontSize: 13.5),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(
                  fontSize: 14, color: KickLoadColors.textDark),
              onSubmitted: (_) => _sendMessage(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: KickLoadColors.primary),
                    onPressed: () {},
                    tooltip: 'Attach file',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: KickLoadColors.primary, size: 20),
                    onPressed: _sendMessage,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: KickLoadColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: KickLoadColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                'History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: KickLoadColors.textDark,
              ),
            ),
          ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search tests...',
              hintStyle:
                  TextStyle(color: KickLoadColors.textMuted, fontSize: 13),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: KickLoadColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: KickLoadColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: KickLoadColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._filteredHistory.map((item) => _buildHistoryTile(item)),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(TestHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KickLoadColors.historyBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fileName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: KickLoadColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.createdAt,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: KickLoadColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert,
              size: 18, color: KickLoadColors.primary),
        ],
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KickLoadColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                // Responsive: side-by-side on wide screens
                if (constraints.maxWidth > 700) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildChatCard()),
                      const SizedBox(width: 20),
                      _buildHistoryPanel(),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildChatCard(),
                    const SizedBox(height: 20),
                    _buildHistoryPanel(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
