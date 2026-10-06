import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/mcq_test_model.dart';
import '../services/firebase_service.dart';
import 'auth_screen.dart';
import 'mcq_player_screen.dart';

class McqDashboardScreen extends StatefulWidget {
  final UserModel user;

  const McqDashboardScreen({super.key, required this.user});

  @override
  State<McqDashboardScreen> createState() => _McqDashboardScreenState();
}

class _McqDashboardScreenState extends State<McqDashboardScreen> {
  List<McqTest> _allTests = [];
  bool _isLoading = true;
  String? _error;
  String _selectedSubject = 'All';
  String _searchQuery = '';

  final List<String> _subjects = [
    'All',
    'Science',
    'Mathematics',
    'Social Science',
    'Hindi',
    'English',
  ];

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tests = await FirebaseService().fetchMcqTests();
      setState(() {
        _allTests = tests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        title: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF111111),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out from Ultra 10th?',
          style: TextStyle(color: Color(0xFF606060)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF606060))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseService().clearUserSession();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  void _showTestIntroModal(McqTest test) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEDEDE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subject Pill (Website B&W Badge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDEDEDE)),
              ),
              child: Text(
                test.subject.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Test Title
            Text(
              test.title,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF111111),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (test.chapter.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                test.chapter,
                style: const TextStyle(
                  color: Color(0xFF606060),
                  fontSize: 14,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Stats row (B&W cards)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildModalStat(
                    icon: Icons.quiz_outlined,
                    label: 'Questions',
                    val: '${test.questions.length}',
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFDEDEDE),
                  ),
                  _buildModalStat(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    val: '${test.durationMinutes} Mins',
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: const Color(0xFFDEDEDE),
                  ),
                  _buildModalStat(
                    icon: Icons.grade_outlined,
                    label: 'Marks',
                    val: '${test.questions.length}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Rules
            Text(
              'Exam Guidelines:',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF111111),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildGuideline('Each question carries 1 mark.'),
            _buildGuideline('Timer starts immediately after clicking Start.'),
            _buildGuideline('Auto-submits when time reaches 00:00.'),
            _buildGuideline('Detailed solutions shown after completion.'),

            const SizedBox(height: 24),

            // Start button (Solid Black CTA)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => McqPlayerScreen(test: test),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Start MCQ Test Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildModalStat({
    required IconData icon,
    required String label,
    required String val,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF111111), size: 20),
        const SizedBox(height: 4),
        Text(
          val,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF111111),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF606060), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF111111), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF606060), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTests = _allTests.where((test) {
      final matchesSubject = _selectedSubject == 'All' ||
          test.subject.toLowerCase() == _selectedSubject.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          test.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          test.chapter.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSubject && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTests,
          color: const Color(0xFF111111),
          backgroundColor: const Color(0xFFFFFFFF),
          child: CustomScrollView(
            slivers: [
              // Top Bar Header (Website Style)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFDEDEDE),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/ultra-10th-logo.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF111111),
                                  child: const Icon(
                                    Icons.quiz_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Namaste, ${widget.user.name.split(' ').first}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF111111),
                                ),
                              ),
                              const Text(
                                'Class 10 Board MCQ Hub',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF606060),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout_rounded, color: Color(0xFF606060)),
                        tooltip: 'Log Out',
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Banner (Website Style B&W)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDEDEDE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE PRACTICE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chapter-wise MCQ Tests\nWith Real Exam Timer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'All questions synced live with ultra10th website.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF606060),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar (White background with crisp line border)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Color(0xFF111111), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search tests by chapter or topic...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF606060),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFFFFF),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF111111), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Subject Filter Tabs (Clean B&W Chips)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _subjects.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, index) {
                      final sub = _subjects[index];
                      final isSelected = sub == _selectedSubject;
                      return ChoiceChip(
                        label: Text(sub),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedSubject = sub),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF111111),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        backgroundColor: const Color(0xFFFFFFFF),
                        selectedColor: const Color(0xFF111111),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF111111) : const Color(0xFFDEDEDE),
                          ),
                        ),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Test List Section
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF111111),
                    ),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: Color(0xFF606060), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF111111), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadTests,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF111111),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (filteredTests.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, color: Color(0xFF999999), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No MCQ tests found for $_selectedSubject',
                          style: const TextStyle(color: Color(0xFF606060), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final test = filteredTests[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFDEDEDE)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x04000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => _showTestIntroModal(test),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row: Subject & Duration
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7F7F7),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: const Color(0xFFDEDEDE)),
                                        ),
                                        child: Text(
                                          test.subject.toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF111111),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, color: Color(0xFF606060), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${test.durationMinutes}m',
                                            style: const TextStyle(
                                              color: Color(0xFF606060),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Test Title
                                  Text(
                                    test.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF111111),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (test.chapter.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      test.chapter,
                                      style: const TextStyle(
                                        color: Color(0xFF606060),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  // Bottom Row: Q count & Start Button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.quiz_outlined, color: Color(0xFF606060), size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${test.questions.length} Questions',
                                            style: const TextStyle(
                                              color: Color(0xFF606060),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF111111),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Start Test',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 13),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filteredTests.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
