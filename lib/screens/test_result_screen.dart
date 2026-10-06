import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mcq_test_model.dart';
import 'mcq_player_screen.dart';

class TestResultScreen extends StatelessWidget {
  final McqTest test;
  final Map<int, int> selectedAnswers;
  final int timeTakenSeconds;

  const TestResultScreen({
    super.key,
    required this.test,
    required this.selectedAnswers,
    required this.timeTakenSeconds,
  });

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    int correctCount = 0;
    int wrongCount = 0;
    int unattemptedCount = 0;

    for (int i = 0; i < test.questions.length; i++) {
      final selected = selectedAnswers[i];
      if (selected == null) {
        unattemptedCount++;
      } else if (selected == test.questions[i].correctOption) {
        correctCount++;
      } else {
        wrongCount++;
      }
    }

    final totalQuestions = test.questions.length;
    final percentage = totalQuestions > 0
        ? ((correctCount / totalQuestions) * 100).round()
        : 0;

    String verdict;
    if (percentage >= 80) {
      verdict = 'Outstanding Performance! 🏆';
    } else if (percentage >= 50) {
      verdict = 'Good Effort, Keep Practicing! 👍';
    } else {
      verdict = 'Needs Revision & Practice 📚';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        title: Text(
          'Test Results',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF111111),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Color(0xFF111111)),
            tooltip: 'Return to Hub',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Scorecard Banner (Website Style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDEDEDE)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Verdict Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDEDEDE)),
                      ),
                      child: Text(
                        verdict,
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Big Score Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$correctCount',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        Text(
                          ' / $totalQuestions',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF606060),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$percentage% Marks Scored',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF606060),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatPill('Correct', '$correctCount', const Color(0xFF10B981)),
                          _buildStatPill('Wrong', '$wrongCount', const Color(0xFFDC2626)),
                          _buildStatPill('Skipped', '$unattemptedCount', const Color(0xFFD97706)),
                          _buildStatPill('Time', _formatTime(timeTakenSeconds), const Color(0xFF111111)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => McqPlayerScreen(test: test),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF111111)),
                      label: const Text('Retake Test', style: TextStyle(color: Color(0xFF111111), fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDEDEDE)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.dashboard_rounded, size: 18),
                      label: const Text('All Tests', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Solutions & Explanations Header
              Text(
                'Question Solutions & Answers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Review your chosen options alongside explanations.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF606060),
                ),
              ),

              const SizedBox(height: 16),

              // Question Review List
              ...List.generate(test.questions.length, (index) {
                final q = test.questions[index];
                final studentAnswer = selectedAnswers[index];
                final isCorrect = studentAnswer == q.correctOption;
                final isSkipped = studentAnswer == null;

                Color statusColor;
                IconData statusIcon;
                String statusLabel;

                if (isSkipped) {
                  statusColor = const Color(0xFFD97706);
                  statusIcon = Icons.remove_circle_outline;
                  statusLabel = 'Unattempted';
                } else if (isCorrect) {
                  statusColor = const Color(0xFF10B981);
                  statusIcon = Icons.check_circle_outline;
                  statusLabel = 'Correct (+1)';
                } else {
                  statusColor = const Color(0xFFDC2626);
                  statusIcon = Icons.cancel_outlined;
                  statusLabel = 'Incorrect (0)';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDEDEDE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFDEDEDE)),
                            ),
                            child: Text(
                              'Q ${index + 1}',
                              style: const TextStyle(
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(statusIcon, color: statusColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Question Text
                      Text(
                        q.question,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Options
                      ...List.generate(q.options.length, (optIdx) {
                        final isStudentChoice = studentAnswer == optIdx;
                        final isCorrectChoice = q.correctOption == optIdx;

                        Color optBg = const Color(0xFFF7F7F7);
                        Color optBorder = const Color(0xFFE5E5E5);
                        Color textColor = const Color(0xFF111111);
                        Widget? trailingIcon;

                        if (isCorrectChoice) {
                          optBg = const Color(0xFFF0FDF4);
                          optBorder = const Color(0xFF86EFAC);
                          textColor = const Color(0xFF166534);
                          trailingIcon = const Icon(Icons.check, color: Color(0xFF166534), size: 16);
                        } else if (isStudentChoice && !isCorrect) {
                          optBg = const Color(0xFFFEF2F2);
                          optBorder = const Color(0xFFFECACA);
                          textColor = const Color(0xFF991B1B);
                          trailingIcon = const Icon(Icons.close, color: Color(0xFF991B1B), size: 16);
                        }

                        final optLetter = String.fromCharCode(65 + optIdx);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: optBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: optBorder),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$optLetter. ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  q.options[optIdx],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isCorrectChoice || isStudentChoice ? FontWeight.w600 : FontWeight.normal,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (trailingIcon != null) trailingIcon,
                            ],
                          ),
                        );
                      }),

                      // Explanation block
                      if (q.explanation.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDEDEDE)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF111111)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Explanation:',
                                      style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      q.explanation,
                                      style: const TextStyle(
                                        color: Color(0xFF606060),
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF606060),
          ),
        ),
      ],
    );
  }
}
