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
    Color verdictColor;
    if (percentage >= 80) {
      verdict = 'Outstanding Performance! 🏆';
      verdictColor = const Color(0xFF10B981);
    } else if (percentage >= 50) {
      verdict = 'Good Effort, Keep Practicing! 👍';
      verdictColor = const Color(0xFF6366F1);
    } else {
      verdict = 'Needs Revision & Hard Work 📚';
      verdictColor = const Color(0xFFF59E0B);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090B10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13161F),
        elevation: 0,
        title: Text(
          'Test Results',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white70),
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
              // Main Scorecard Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E2330), Color(0xFF13161F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    // Verdict Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: verdictColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: verdictColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        verdict,
                        style: TextStyle(
                          color: verdictColor,
                          fontWeight: FontWeight.bold,
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
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' / $totalQuestions',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$percentage% Marks Scored',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatPill('Correct', '$correctCount', const Color(0xFF10B981)),
                        _buildStatPill('Wrong', '$wrongCount', const Color(0xFFEF4444)),
                        _buildStatPill('Skipped', '$unattemptedCount', const Color(0xFFF59E0B)),
                        _buildStatPill('Time', _formatTime(timeTakenSeconds), const Color(0xFF818CF8)),
                      ],
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
                      icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                      label: const Text('Retake Test', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.15)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.dashboard_rounded, size: 18, color: Colors.white),
                      label: const Text('All Tests', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
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
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Review your selected answers alongside full step-by-step explanations.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),

              const SizedBox(height: 16),

              // Question Review List
              ...List.generate(test.questions.length, (index) {
                final q = test.questions[index];
                final studentAnswer = selectedAnswers[index];
                final isCorrect = studentAnswer == q.correctOption;
                final isSkipped = studentAnswer == null;

                Color cardColor;
                IconData statusIcon;
                Color statusColor;

                if (isSkipped) {
                  cardColor = const Color(0xFFF59E0B).withOpacity(0.08);
                  statusIcon = Icons.remove_circle_outline;
                  statusColor = const Color(0xFFF59E0B);
                } else if (isCorrect) {
                  cardColor = const Color(0xFF10B981).withOpacity(0.08);
                  statusIcon = Icons.check_circle_outline;
                  statusColor = const Color(0xFF10B981);
                } else {
                  cardColor = const Color(0xFFEF4444).withOpacity(0.08);
                  statusIcon = Icons.cancel_outlined;
                  statusColor = const Color(0xFFEF4444);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13161F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Q ${index + 1}',
                              style: TextStyle(
                                color: statusColor,
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
                                isSkipped
                                    ? 'Unattempted'
                                    : isCorrect
                                        ? 'Correct (+1)'
                                        : 'Incorrect (0)',
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
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Options
                      ...List.generate(q.options.length, (optIdx) {
                        final isStudentChoice = studentAnswer == optIdx;
                        final isCorrectChoice = q.correctOption == optIdx;

                        Color optBg = const Color(0xFF1E2330);
                        Color optBorder = Colors.transparent;
                        Widget? trailingIcon;

                        if (isCorrectChoice) {
                          optBg = const Color(0xFF10B981).withOpacity(0.15);
                          optBorder = const Color(0xFF10B981);
                          trailingIcon = const Icon(Icons.check, color: Color(0xFF10B981), size: 16);
                        } else if (isStudentChoice && !isCorrect) {
                          optBg = const Color(0xFFEF4444).withOpacity(0.15);
                          optBorder = const Color(0xFFEF4444);
                          trailingIcon = const Icon(Icons.close, color: Color(0xFFEF4444), size: 16);
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
                                  color: isCorrectChoice
                                      ? const Color(0xFF10B981)
                                      : isStudentChoice
                                          ? const Color(0xFFEF4444)
                                          : Colors.white60,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  q.options[optIdx],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isCorrectChoice || isStudentChoice
                                        ? Colors.white
                                        : Colors.white70,
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
                            color: const Color(0xFF1E2330).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFFBBF24)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Explanation:',
                                      style: TextStyle(
                                        color: Color(0xFFFBBF24),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      q.explanation,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        height: 1.3,
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
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
