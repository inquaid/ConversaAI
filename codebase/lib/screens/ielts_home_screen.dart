import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ielts_models.dart';
import '../providers/ielts_provider.dart';

/// IELTS home screen showing available exams and user's progress
class IELTSHomeScreen extends StatefulWidget {
  const IELTSHomeScreen({Key? key}) : super(key: key);

  @override
  State<IELTSHomeScreen> createState() => _IELTSHomeScreenState();
}

class _IELTSHomeScreenState extends State<IELTSHomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  /// Initialize the user profile
  Future<void> _initializeUser() async {
    final provider = Provider.of<IELTSProvider>(context, listen: false);
    await provider.initializeUserProfile(
      'user123',
    ); // Replace with actual user ID

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Preparation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile screen
              // Navigator.push(context, MaterialPageRoute(builder: (_) => IELTSProfileScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<IELTSProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserScoreCard(context, provider),
                      const SizedBox(height: 24.0),
                      _buildAvailableExams(context, provider),
                      const SizedBox(height: 24.0),
                      _buildRecentAttempts(context, provider),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to practice section selector
          // Navigator.push(context, MaterialPageRoute(builder: (_) => IELTSPracticeScreen()));
        },
        icon: const Icon(Icons.fitness_center),
        label: const Text('Practice'),
      ),
    );
  }

  /// Build a card showing the user's highest scores
  Widget _buildUserScoreCard(BuildContext context, IELTSProvider provider) {
    final theme = Theme.of(context);
    final userProfile = provider.userProfile;
    final highestScore = userProfile?.highestScore;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your IELTS Score', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16.0),
            if (highestScore != null) ...[
              _buildScoreRow('Overall', highestScore.overall),
              const Divider(),
              _buildScoreRow('Listening', highestScore.listening ?? 0.0),
              _buildScoreRow('Reading', highestScore.reading ?? 0.0),
              _buildScoreRow('Writing', highestScore.writing ?? 0.0),
              _buildScoreRow('Speaking', highestScore.speaking ?? 0.0),
            ] else ...[
              Text(
                'Complete your first exam to see your scores',
                style: theme.textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Navigate to detailed scores history
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => IELTSScoreHistoryScreen()));
                },
                child: const Text('View History'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a row showing a score for a section
  Widget _buildScoreRow(String title, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), _buildScoreBadge(score)],
      ),
    );
  }

  /// Build a badge showing a score with appropriate color
  Widget _buildScoreBadge(double score) {
    Color color;
    if (score >= 7.0) {
      color = Colors.green;
    } else if (score >= 6.0) {
      color = Colors.amber;
    } else if (score > 0) {
      color = Colors.red;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color),
      ),
      child: Text(
        score > 0 ? score.toString() : 'N/A',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Build a list of available exams
  Widget _buildAvailableExams(BuildContext context, IELTSProvider provider) {
    final theme = Theme.of(context);
    final exams = provider.exams;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Tests', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16.0),
        if (exams.isEmpty)
          const Text('No exams available')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  title: Text(exam.title),
                  subtitle: Text(exam.type.name),
                  trailing: exam.isOfficial
                      ? const Chip(
                          label: Text('Official'),
                          backgroundColor: Colors.blue,
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      : null,
                  onTap: () => _startExam(context, exam.id),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Build a list of recent test attempts
  Widget _buildRecentAttempts(BuildContext context, IELTSProvider provider) {
    final theme = Theme.of(context);
    final attempts = provider.userAttempts;

    // Only show recent and completed attempts
    final recentAttempts = attempts.where((a) => a.isCompleted).toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    // Take only the most recent 3
    final displayAttempts = recentAttempts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Attempts', style: theme.textTheme.titleLarge),
            if (recentAttempts.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to all attempts history
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => IELTSAttemptsScreen()));
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16.0),
        if (displayAttempts.isEmpty)
          const Text('No test attempts yet')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayAttempts.length,
            itemBuilder: (context, index) {
              final attempt = displayAttempts[index];
              // Find the corresponding exam
              final exam = provider.exams.firstWhere(
                (e) => e.id == attempt.examId,
                orElse: () => IELTSExam(
                  id: 'unknown',
                  title: 'Unknown Exam',
                  type: IELTSExamType.academic,
                  content: {},
                  createdAt: DateTime.now(),
                ),
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  title: Text(exam.title),
                  subtitle: Text(
                    'Completed on ${_formatDate(attempt.completedAt!)}',
                  ),
                  trailing: attempt.score != null
                      ? _buildScoreBadge(attempt.score!.overall)
                      : null,
                  onTap: () {
                    // Navigate to attempt details
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (_) => IELTSAttemptDetailsScreen(attemptId: attempt.id),
                    // ));
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  /// Start a new exam
  Future<void> _startExam(BuildContext context, String examId) async {
    final provider = Provider.of<IELTSProvider>(context, listen: false);

    // Show confirmation dialog
    final shouldStart =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Start IELTS Test'),
            content: const Text(
              'This test will take approximately 2.5 hours to complete. Make sure you have a quiet environment and enough time. You can pause and resume later if needed.\n\nAre you ready to begin?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('START TEST'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldStart) return;

    // Start the exam
    final attempt = await provider.startExam(examId);

    if (attempt != null && mounted) {
      // Navigate to exam screen
      // Navigator.push(context, MaterialPageRoute(
      //   builder: (_) => IELTSExamScreen(attemptId: attempt.id),
      // ));
    }
  }

  /// Format a date as a readable string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
