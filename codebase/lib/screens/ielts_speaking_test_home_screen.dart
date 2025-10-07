/// IELTS Speaking Test Home Screen - Select test duration and view history
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ielts_speaking_test_models.dart';
import '../providers/ielts_speaking_test_provider.dart';
import 'ielts_speaking_test_screen.dart';
import 'ielts_speaking_test_results_screen.dart';

class IELTSSpeakingTestHomeScreen extends StatelessWidget {
  const IELTSSpeakingTestHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Speaking Test'),
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Consumer<IELTSSpeakingTestProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome section
                    _buildWelcomeCard(context, provider),
                    const SizedBox(height: 30),

                    // Test duration options
                    const Text(
                      'Choose Test Duration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Duration cards
                    _buildDurationCard(
                      context,
                      provider,
                      SpeakingTestDuration.short,
                      Icons.flash_on,
                      Colors.orange,
                    ),
                    const SizedBox(height: 15),
                    _buildDurationCard(
                      context,
                      provider,
                      SpeakingTestDuration.medium,
                      Icons.timer,
                      Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    _buildDurationCard(
                      context,
                      provider,
                      SpeakingTestDuration.full,
                      Icons.star,
                      Colors.green,
                    ),
                    const SizedBox(height: 30),

                    // Test history
                    if (provider.completedTests.isNotEmpty) ...[
                      _buildHistorySection(context, provider),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(
    BuildContext context,
    IELTSSpeakingTestProvider provider,
  ) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [Colors.white, Colors.blue.shade50]),
        ),
        child: Column(
          children: [
            const Icon(Icons.mic, size: 60, color: Color(0xFF1565C0)),
            const SizedBox(height: 15),
            const Text(
              'Welcome to IELTS Speaking Practice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Practice with authentic IELTS questions and get AI-powered feedback on your performance.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            if (provider.totalTestsCompleted > 0) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Tests',
                    provider.totalTestsCompleted.toString(),
                    Icons.assessment,
                  ),
                  _buildStatItem(
                    'Average',
                    provider.averageBandScore?.toStringAsFixed(1) ?? '-',
                    Icons.trending_up,
                  ),
                  _buildStatItem(
                    'Best',
                    provider.highestBandScore?.toStringAsFixed(1) ?? '-',
                    Icons.star,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1565C0), size: 28),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDurationCard(
    BuildContext context,
    IELTSSpeakingTestProvider provider,
    SpeakingTestDuration duration,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _startTest(context, provider, duration),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.1)],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 35, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      duration.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      duration.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    IELTSSpeakingTestProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Tests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (provider.completedTests.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to full history
                },
                child: const Text(
                  'View All',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        ...provider.completedTests.take(3).map((test) {
          return _buildHistoryCard(context, test);
        }).toList(),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, SpeakingTestSession test) {
    final evaluation = test.evaluation;
    final bandScore = evaluation?.criteria.overallBand ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  IELTSSpeakingTestResultsScreen(testSession: test),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: _getBandColor(bandScore),
          child: Text(
            bandScore.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          test.duration.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatDate(test.completedAt ?? test.startedAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _getBandColor(double band) {
    if (band >= 8.0) return Colors.green;
    if (band >= 6.5) return Colors.blue;
    if (band >= 5.0) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _startTest(
    BuildContext context,
    IELTSSpeakingTestProvider provider,
    SpeakingTestDuration duration,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      await provider.startTest(duration);

      if (!context.mounted) return;

      // Close loading
      Navigator.pop(context);

      // Navigate to test screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const IELTSSpeakingTestScreen(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // Close loading
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start test: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
