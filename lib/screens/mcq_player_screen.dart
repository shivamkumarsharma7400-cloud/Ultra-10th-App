import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mcq_test_model.dart';
import 'test_result_screen.dart';

class McqPlayerScreen extends StatefulWidget {
  final McqTest test;

  const McqPlayerScreen({super.key, required this.test});

  @override
  State<McqPlayerScreen> createState() => _McqPlayerScreenState();
}

class _McqPlayerScreenState extends State<McqPlayerScreen> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // { qIndex: optIndex }
  late int _timeLeftSeconds;
  int _timeTakenSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeftSeconds = widget.test.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeftSeconds <= 1) {
        timer.cancel();
        _submitTest(autoSubmit: true);
      } else {
        setState(() {
          _timeLeftSeconds--;
          _timeTakenSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectOption(int optIndex) {
    setState(() {
      _selectedAnswers[_currentIndex] = optIndex;
    });
  }

  void _clearChoice() {
    setState(() {
      _selectedAnswers.remove(_currentIndex);
    });
  }

  void _openPaletteSheet() {
    showModalBottomSheet(
      context: context,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question Palette',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_selectedAnswers.length} of ${widget.test.questions.length} Attempted',
                  style: const TextStyle(
                    color: Color(0xFF606060),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(widget.test.questions.length, (index) {
                final isAnswered = _selectedAnswers.containsKey(index);
                final isCurrent = index == _currentIndex;

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _currentIndex = index);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF111111)
                          : isAnswered
                              ? const Color(0xFFF0F0F0)
                              : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFF111111)
                            : isAnswered
                                ? const Color(0xFF111111)
                                : const Color(0xFFDEDEDE),
                        width: isAnswered || isCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : const Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmSubmit() {
    final total = widget.test.questions.length;
    final attempted = _selectedAnswers.length;
    final unattempted = total - attempted;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        title: Text(
          'Submit Test?',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF111111),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to finish and submit your test?',
              style: TextStyle(color: Color(0xFF606060), fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$attempted',
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text('Attempted', style: TextStyle(color: Color(0xFF606060), fontSize: 11)),
                    ],
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFFDEDEDE)),
                  Column(
                    children: [
                      Text(
                        '$unattempted',
                        style: const TextStyle(
                          color: Color(0xFF606060),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Text('Unattempted', style: TextStyle(color: Color(0xFF606060), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF606060))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitTest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit Now'),
          ),
        ],
      ),
    );
  }

  void _submitTest({bool autoSubmit = false}) {
    _timer?.cancel();

    if (autoSubmit && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time up! Test submitted automatically.'),
          backgroundColor: Color(0xFF111111),
        ),
      );
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TestResultScreen(
          test: widget.test,
          selectedAnswers: _selectedAnswers,
          timeTakenSeconds: _timeTakenSeconds,
        ),
      ),
    );
  }

  Future<bool> _handleExitAttempt() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        title: Text(
          'Leave Test?',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF111111),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          'Leaving will discard your current progress in this test. Do you really want to exit?',
          style: TextStyle(color: Color(0xFF606060)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Taking Test', style: TextStyle(color: Color(0xFF606060))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Exit Test'),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.test.questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
        ),
        body: const Center(
          child: Text('No questions available in this test.', style: TextStyle(color: Color(0xFF111111))),
        ),
      );
    }

    final currentQ = widget.test.questions[_currentIndex];
    final isLowTime = _timeLeftSeconds < 120;
    final totalQuestions = widget.test.questions.length;

    return WillPopScope(
      onWillPop: _handleExitAttempt,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF111111)),
            onPressed: () async {
              if (await _handleExitAttempt()) {
                if (mounted) Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Q ${_currentIndex + 1} / $totalQuestions',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF111111),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          actions: [
            // Timer Badge
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isLowTime ? const Color(0xFFFEF2F2) : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLowTime ? const Color(0xFFFECACA) : const Color(0xFFDEDEDE),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 15,
                    color: isLowTime ? const Color(0xFFDC2626) : const Color(0xFF111111),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(_timeLeftSeconds),
                    style: TextStyle(
                      color: isLowTime ? const Color(0xFFDC2626) : const Color(0xFF111111),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.grid_view_rounded, color: Color(0xFF111111)),
              tooltip: 'Question Palette',
              onPressed: _openPaletteSheet,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Line
              LinearProgressIndicator(
                value: (_currentIndex + 1) / totalQuestions,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF111111)),
                minHeight: 3,
              ),

              // Question & Options Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Number & Clear
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFDEDEDE)),
                            ),
                            child: Text(
                              'QUESTION ${_currentIndex + 1}',
                              style: const TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          if (_selectedAnswers.containsKey(_currentIndex))
                            TextButton.icon(
                              onPressed: _clearChoice,
                              icon: const Icon(Icons.refresh, size: 14, color: Color(0xFF606060)),
                              label: const Text('Clear choice', style: TextStyle(color: Color(0xFF606060), fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Question Card (Website Style)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDEDEDE)),
                        ),
                        child: Text(
                          currentQ.question,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Options List
                      ...List.generate(currentQ.options.length, (optIndex) {
                        final isSelected = _selectedAnswers[_currentIndex] == optIndex;
                        final optLabel = String.fromCharCode(65 + optIndex); // A, B, C, D

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _selectOption(optIndex),
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF111111)
                                      : const Color(0xFFDEDEDE),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    const BoxShadow(
                                      color: Color(0x0A000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Option Badge (A, B, C, D)
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF111111)
                                          : const Color(0xFFF7F7F7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF111111)
                                            : const Color(0xFFDEDEDE),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        optLabel,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : const Color(0xFF111111),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Option Text
                                  Expanded(
                                    child: Text(
                                      currentQ.options[optIndex],
                                      style: TextStyle(
                                        color: const Color(0xFF111111),
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom Control Bar (Pure White with line border)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5E5E5)),
                  ),
                ),
                child: Row(
                  children: [
                    // Previous Button
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentIndex--),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDEDEDE)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Previous', style: TextStyle(color: Color(0xFF111111), fontWeight: FontWeight.w600)),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 12),

                    // Next or Submit Button
                    if (_currentIndex < totalQuestions - 1)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => _currentIndex++),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111111),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _confirmSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF111111),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Submit Test',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
