import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  THEME CONSTANTS  (shared across both screens)
// ─────────────────────────────────────────────
class KickLoadColors {
  static const background = AppColors.bg;
  static const cardBg = AppColors.card;
  static const primary = AppColors.blue;
  static const primaryLight = Color(0xFF12263F);
  static const textDark = AppColors.textPrimary;
  static const textMuted = AppColors.textSecondary;
  static const border = AppColors.cardBorder;
  static const historyBg = Color(0xFF111827);
  static const checkboxActive = AppColors.green;
}

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────
class RunHistoryItem {
  final String fileName;
  final String ranAt;
  RunHistoryItem({required this.fileName, required this.ranAt});
}

enum SamplerErrorAction { continueAction, startNextLoop, stopThread, stopTest, stopTestNow }

// ─────────────────────────────────────────────
//  RUN TEST SCREEN
// ─────────────────────────────────────────────
class RunTestScreen extends StatefulWidget {
  const RunTestScreen({super.key});

  @override
  State<RunTestScreen> createState() => _RunTestScreenState();
}

class _RunTestScreenState extends State<RunTestScreen> {
  // ── Form state ──────────────────────────────
  String _selectedJmx = 'test_plan_16-03-2026_10-43-36_16-03-2026_12-45-03.jmx';
  final TextEditingController _usersCtrl =
      TextEditingController(text: '40');
  final TextEditingController _rampUpCtrl =
      TextEditingController(text: '180');
  final TextEditingController _loopCountCtrl =
      TextEditingController(text: '1');
  final TextEditingController _durationCtrl =
      TextEditingController(text: '60');
  final TextEditingController _startupDelayCtrl =
      TextEditingController(text: '0');

  bool _sameUserOnEachIteration = true;
  bool _delayThreadCreation = false;
  bool _specifyThreadLifetime = true;

  SamplerErrorAction _samplerErrorAction = SamplerErrorAction.continueAction;

  bool _isRunning = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _jmxFiles = [
    'test_plan_16-03-2026_10-43-36_16-03-2026_12-45-03.jmx',
    'test_plan_23-03-2026_08-07-45.jmx',
    'demo_load_test_advanced_1.jmx',
  ];

  final List<RunHistoryItem> _history = [
    RunHistoryItem(
        fileName:
            'test_plan_19-03-2026_09-51-13_Load_Test_Users_40_180_1.pdf',
        ranAt: 'Ran: 19/03/2026, 15:24:21'),
    RunHistoryItem(
        fileName:
            'test_plan_17-03-2026_14-19-59_Load_Test_Users_40_180_1.pdf',
        ranAt: 'Ran: 17/03/2026, 19:53:09'),
    RunHistoryItem(
        fileName:
            'test_plan_16-03-2026_12-45-16_Load_Test_Users_40_180_1.pdf',
        ranAt: 'Ran: 16/03/2026, 18:18:23'),
  ];

  @override
  void dispose() {
    _usersCtrl.dispose();
    _rampUpCtrl.dispose();
    _loopCountCtrl.dispose();
    _durationCtrl.dispose();
    _startupDelayCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<RunHistoryItem> get _filteredHistory {
    if (_searchQuery.isEmpty) return _history;
    return _history
        .where((item) =>
            item.fileName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ── HELPERS ──────────────────────────────────

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(fontSize: 12, color: KickLoadColors.textMuted),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: KickLoadColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: KickLoadColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide:
            const BorderSide(color: KickLoadColors.primary, width: 1.5),
      ),
    );
  }

  // ── SECTION WIDGETS ──────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Run KickLoad Test',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: KickLoadColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Execute your performance tests seamlessly!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: KickLoadColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectTestPlan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: KickLoadColors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Select Test Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: KickLoadColors.textDark,
                  ),
                ),
              ],
            ),
            OutlinedButton(
              onPressed: () => setState(() => _selectedJmx = _jmxFiles.first),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: KickLoadColors.border),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text(
                'CLEAR TEST PLAN',
                style: TextStyle(
                  fontSize: 11,
                  color: KickLoadColors.textDark,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // JMX dropdown
        DropdownButtonFormField<String>(
          value: _selectedJmx,
          isExpanded: true,
          decoration: _fieldDecoration('Select JMX File'),
          items: _jmxFiles
              .map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedJmx = v ?? _selectedJmx),
        ),
      ],
    );
  }

  Widget _buildConfigureParameters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configure Test Parameters',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: KickLoadColors.textDark,
          ),
        ),
        const SizedBox(height: 14),

        // Row 1: Users / Ramp-Up / Loop Count
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _usersCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration('Number of Users'),
                  ),
                  const SizedBox(height: 4),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Max users: 9,990',
                      style: TextStyle(
                          fontSize: 11, color: KickLoadColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _rampUpCtrl,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Ramp-Up Time (s)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _loopCountCtrl,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Loop Count'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row 2: Checkboxes (left) + Duration / Startup Delay (right)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkboxes column
            Expanded(
              child: Column(
                children: [
                  _buildCheckboxRow(
                    label: 'Same User on Each Iteration',
                    value: _sameUserOnEachIteration,
                    onChanged: (v) =>
                        setState(() => _sameUserOnEachIteration = v ?? false),
                  ),
                  const SizedBox(height: 8),
                  _buildCheckboxRow(
                    label: 'Delay Thread Creation Until Needed',
                    value: _delayThreadCreation,
                    onChanged: (v) =>
                        setState(() => _delayThreadCreation = v ?? false),
                  ),
                  const SizedBox(height: 8),
                  _buildCheckboxRow(
                    label: 'Specify Thread Lifetime',
                    value: _specifyThreadLifetime,
                    onChanged: (v) =>
                        setState(() => _specifyThreadLifetime = v ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Duration + Startup Delay column
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration('Duration (s)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _startupDelayCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration('Startup Delay (s)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: KickLoadColors.checkboxActive,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13.5, color: KickLoadColors.textDark)),
        ),
      ],
    );
  }

  Widget _buildSamplerErrorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Action to be taken after a Sampler error',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: KickLoadColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildRadioOption(
                'Continue', SamplerErrorAction.continueAction),
            _buildRadioOption(
                'Start Next Thread Loop', SamplerErrorAction.startNextLoop),
            _buildRadioOption(
                'Stop Thread', SamplerErrorAction.stopThread),
            _buildRadioOption('Stop Test', SamplerErrorAction.stopTest),
            _buildRadioOption(
                'Stop Test Now', SamplerErrorAction.stopTestNow),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, SamplerErrorAction value) {
    return SizedBox(
      width: 180,
      child: Row(
        children: [
          Radio<SamplerErrorAction>(
            value: value,
            groupValue: _samplerErrorAction,
            onChanged: (v) => setState(() => _samplerErrorAction = v!),
            activeColor: KickLoadColors.primary,
          ),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13.5, color: KickLoadColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Run / Stop row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isRunning
                    ? null
                    : () => setState(() => _isRunning = true),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  'Run Test',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KickLoadColors.primary,
                  disabledBackgroundColor:
                      KickLoadColors.primary.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isRunning
                    ? () => setState(() => _isRunning = false)
                    : null,
                icon: Icon(Icons.stop,
                    color: _isRunning
                        ? Colors.white
                        : KickLoadColors.textMuted),
                label: Text(
                  'Stop Test',
                  style: TextStyle(
                    color: _isRunning
                        ? Colors.white
                        : KickLoadColors.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Download / Email row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined,
                    color: KickLoadColors.textDark, size: 18),
                label: const Text(
                  'Download (PDF)',
                  style: TextStyle(
                      color: KickLoadColors.textDark, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: KickLoadColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.email_outlined,
                    color: KickLoadColors.textDark, size: 18),
                label: const Text(
                  'Email Results',
                  style: TextStyle(
                      color: KickLoadColors.textDark, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: KickLoadColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainCard() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectTestPlan(),
          const SizedBox(height: 24),
          _buildConfigureParameters(),
          const SizedBox(height: 24),
          _buildSamplerErrorSection(),
          const SizedBox(height: 28),
          _buildActionButtons(),
        ],
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
            color: Colors.black.withOpacity(0.06),
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
              hintText: 'Search files...',
              hintStyle: TextStyle(
                  color: KickLoadColors.textMuted, fontSize: 13),
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

  Widget _buildHistoryTile(RunHistoryItem item) {
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
                  item.ranAt,
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
                if (constraints.maxWidth > 700) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMainCard()),
                      const SizedBox(width: 20),
                      _buildHistoryPanel(),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildMainCard(),
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
