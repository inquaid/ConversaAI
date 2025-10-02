import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ielts_models.dart';
import '../providers/ielts_provider.dart';

/// Screen for taking an IELTS exam
class IELTSExamScreen extends StatefulWidget {
  final String attemptId;

  const IELTSExamScreen({Key? key, required this.attemptId}) : super(key: key);

  @override
  State<IELTSExamScreen> createState() => _IELTSExamScreenState();
}

class _IELTSExamScreenState extends State<IELTSExamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isLoading = false;
  IELTSSection _currentSection = IELTSSection.listening;

  // Answers for each section
  final Map<IELTSSection, dynamic> _sectionAnswers = {
    IELTSSection.listening: [],
    IELTSSection.reading: [],
    IELTSSection.writing: {'task1': '', 'task2': ''},
    IELTSSection.speaking: {'part1': {}, 'part2': '', 'part3': {}},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _startTimer();

    // Set initial section based on exam progress
    _loadCurrentAttempt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  /// Load the current attempt data
  void _loadCurrentAttempt() {
    final provider = Provider.of<IELTSProvider>(context, listen: false);
    final attempt = provider.currentAttempt;

    if (attempt != null) {
      // Determine which section to start with based on completed sections
      for (final section in IELTSSection.values) {
        if (!attempt.completedSections[section]!) {
          setState(() {
            _currentSection = section;
            _tabController.index = section.index;
          });
          break;
        }
      }
    }
  }

  /// Handle tab change
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Save answers for current section before switching
      _saveCurrentSectionAnswers();

      // Update current section
      setState(() {
        _currentSection = IELTSSection.values[_tabController.index];
        _secondsElapsed = 0; // Reset timer for new section
      });

      // Restart timer
      _startTimer();
    }
  }

  /// Start section timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  /// Save answers for the current section
  Future<void> _saveCurrentSectionAnswers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<IELTSProvider>(context, listen: false);
      await provider.saveSectionAnswers(
        section: _currentSection,
        answers: _sectionAnswers[_currentSection]!,
        timeSpentSeconds: _secondsElapsed,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Complete the entire exam
  Future<void> _completeExam() async {
    // Save the current section first
    await _saveCurrentSectionAnswers();

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<IELTSProvider>(context, listen: false);
      final score = await provider.completeExam();

      if (score != null && mounted) {
        // Show completion dialog with score
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Exam Completed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your IELTS score:'),
                const SizedBox(height: 16.0),
                _buildScoreTable(score),
                const SizedBox(height: 16.0),
                Text(
                  'Overall: ${score.overall}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigate back to home screen
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('FINISH'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Build a table showing the scores for each section
  Widget _buildScoreTable(IELTSBandScore score) {
    return Table(
      border: TableBorder.all(),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Colors.grey),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Section',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Score',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Listening'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(score.listening?.toString() ?? 'N/A'),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(padding: EdgeInsets.all(8.0), child: Text('Reading')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(score.reading?.toString() ?? 'N/A'),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(padding: EdgeInsets.all(8.0), child: Text('Writing')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(score.writing?.toString() ?? 'N/A'),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Speaking'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(score.speaking?.toString() ?? 'N/A'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before exiting
        final shouldExit =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Exam?'),
                content: const Text(
                  'Your progress will be saved, but the timer will continue. You can resume later.\n\nAre you sure you want to exit?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('EXIT'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldExit) {
          // Save current section before exiting
          await _saveCurrentSectionAnswers();
        }

        return shouldExit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IELTS Exam'),
          bottom: TabBar(
            controller: _tabController,
            tabs: IELTSSection.values.map((section) {
              return Tab(text: section.name);
            }).toList(),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _formatTime(_secondsElapsed),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<IELTSProvider>(
                builder: (context, provider, child) {
                  final attempt = provider.currentAttempt;
                  final exam = provider.currentExam;

                  if (attempt == null || exam == null) {
                    return const Center(child: Text('Error loading exam data'));
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Listening Section
                      _buildListeningSection(exam, attempt),

                      // Reading Section
                      _buildReadingSection(exam, attempt),

                      // Writing Section
                      _buildWritingSection(exam, attempt),

                      // Speaking Section
                      _buildSpeakingSection(exam, attempt),
                    ],
                  );
                },
              ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Move to previous section if not the first
                    if (_tabController.index > 0) {
                      _tabController.animateTo(_tabController.index - 1);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                if (_tabController.index == IELTSSection.values.length - 1)
                  ElevatedButton(
                    onPressed: _completeExam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('COMPLETE EXAM'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      // Save current section and move to next
                      _saveCurrentSectionAnswers().then((_) {
                        if (_tabController.index <
                            IELTSSection.values.length - 1) {
                          _tabController.animateTo(_tabController.index + 1);
                        }
                      });
                    },
                    child: const Text('NEXT SECTION'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the listening section UI
  Widget _buildListeningSection(IELTSExam exam, IELTSAttempt attempt) {
    final content = exam.content[IELTSSection.listening];

    if (content == null || content.isEmpty) {
      return const Center(child: Text('No listening content available'));
    }

    // For a real app, this would be a more complex UI with audio player
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'IELTS Listening Test',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Instructions:',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            '1. You will hear a series of audio recordings and answer questions based on what you hear.\n'
            '2. Click the Play button to start each recording.\n'
            '3. You can play each recording only ONCE.\n'
            '4. Answer all questions before moving to the next section.\n',
          ),
          const SizedBox(height: 16.0),

          // Audio player (simplified for demo)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Listening Recording'),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Play audio
                        },
                        icon: const Icon(Icons.play_circle_filled, size: 48.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Questions
          ...content.asMap().entries.map((entry) {
            final part = entry.value;
            final questions = part['questions'] as List<dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Section ${entry.key + 1}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                ...questions.asMap().entries.map((qEntry) {
                  final question = qEntry.value;
                  final questionId = question['id'] as String;
                  final questionText = question['text'] as String;

                  // Make sure the answers list is big enough
                  while (_sectionAnswers[IELTSSection.listening]!.length <=
                      qEntry.key) {
                    _sectionAnswers[IELTSSection.listening]!.add('');
                  }

                  return ListTile(
                    title: Text('${qEntry.key + 1}. $questionText'),
                    subtitle: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your answer',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _sectionAnswers[IELTSSection.listening]![qEntry.key] =
                              value;
                        });
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24.0),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Build the reading section UI
  Widget _buildReadingSection(IELTSExam exam, IELTSAttempt attempt) {
    final content = exam.content[IELTSSection.reading];

    if (content == null || content.isEmpty) {
      return const Center(child: Text('No reading content available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'IELTS Reading Test',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Instructions:',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            '1. Read each passage carefully.\n'
            '2. Answer all questions based on the information in the passages.\n'
            '3. You have 60 minutes to complete this section.\n',
          ),
          const SizedBox(height: 16.0),

          // Passages and questions
          ...content.asMap().entries.map((entry) {
            final part = entry.value;
            final passageText = part['text'] as String;
            final questions = part['questions'] as List<dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Passage ${entry.key + 1}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Passage text
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(passageText),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Questions
                Text(
                  'Questions ${entry.key + 1}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                ...questions.asMap().entries.map((qEntry) {
                  final question = qEntry.value;
                  final questionId = question['id'] as String;
                  final questionText = question['text'] as String;
                  final options = question['options'] as List<dynamic>? ?? [];

                  // Calculate the actual index across all passages
                  int totalIndex = 0;
                  for (int i = 0; i < entry.key; i++) {
                    totalIndex += (content[i]['questions'] as List).length;
                  }
                  totalIndex += qEntry.key;

                  // Make sure the answers list is big enough
                  while (_sectionAnswers[IELTSSection.reading]!.length <=
                      totalIndex) {
                    _sectionAnswers[IELTSSection.reading]!.add('');
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${totalIndex + 1}. $questionText'),
                      const SizedBox(height: 8.0),
                      if (options.isNotEmpty)
                        ...options.map((option) {
                          return RadioListTile<String>(
                            title: Text(option as String),
                            value: option,
                            groupValue:
                                _sectionAnswers[IELTSSection
                                    .reading]![totalIndex],
                            onChanged: (value) {
                              setState(() {
                                _sectionAnswers[IELTSSection
                                        .reading]![totalIndex] =
                                    value!;
                              });
                            },
                          );
                        }).toList()
                      else
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Enter your answer',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _sectionAnswers[IELTSSection
                                      .reading]![totalIndex] =
                                  value;
                            });
                          },
                        ),
                      const SizedBox(height: 16.0),
                    ],
                  );
                }).toList(),
                const Divider(height: 32.0),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Build the writing section UI
  Widget _buildWritingSection(IELTSExam exam, IELTSAttempt attempt) {
    final content = exam.content[IELTSSection.writing];

    if (content == null || content.isEmpty) {
      return const Center(child: Text('No writing content available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'IELTS Writing Test',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Instructions:',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            '1. This section consists of two tasks.\n'
            '2. You should spend about 20 minutes on Task 1 and 40 minutes on Task 2.\n'
            '3. Task 1 requires at least 150 words. Task 2 requires at least 250 words.\n',
          ),
          const SizedBox(height: 16.0),

          // Task 1
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task 1',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(content[0]['description'] as String),
                  const SizedBox(height: 8.0),
                  if (content[0].containsKey('imageUrl'))
                    Image.asset(
                      content[0]['imageUrl'] as String,
                      height: 200.0,
                      fit: BoxFit.contain,
                    ),
                  const SizedBox(height: 16.0),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Write your answer here...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                    onChanged: (value) {
                      setState(() {
                        _sectionAnswers[IELTSSection.writing]!['task1'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Word count: ${_countWords(_sectionAnswers[IELTSSection.writing]!['task1'])} / ${content[0]['wordCount']}',
                    style: TextStyle(
                      color:
                          _countWords(
                                _sectionAnswers[IELTSSection.writing]!['task1'],
                              ) <
                              (content[0]['wordCount'] as int)
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Task 2
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task 2',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(content[1]['description'] as String),
                  const SizedBox(height: 16.0),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Write your answer here...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 15,
                    onChanged: (value) {
                      setState(() {
                        _sectionAnswers[IELTSSection.writing]!['task2'] = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Word count: ${_countWords(_sectionAnswers[IELTSSection.writing]!['task2'])} / ${content[1]['wordCount']}',
                    style: TextStyle(
                      color:
                          _countWords(
                                _sectionAnswers[IELTSSection.writing]!['task2'],
                              ) <
                              (content[1]['wordCount'] as int)
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the speaking section UI
  Widget _buildSpeakingSection(IELTSExam exam, IELTSAttempt attempt) {
    final content = exam.content[IELTSSection.speaking];

    if (content == null || content.isEmpty) {
      return const Center(child: Text('No speaking content available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'IELTS Speaking Test',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Instructions:',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            '1. This section consists of three parts.\n'
            '2. Part 1: Introduction and general questions (4-5 minutes).\n'
            '3. Part 2: Individual long turn on a given topic (3-4 minutes).\n'
            '4. Part 3: Two-way discussion on related topics (4-5 minutes).\n'
            '5. Click the microphone button to record your answers.\n',
          ),
          const SizedBox(height: 16.0),

          // Part 1
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Part 1: Introduction and General Questions',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ...content[0]['topics'][0]['questions'].asMap().entries.map((
                    entry,
                  ) {
                    final question = entry.value as String;
                    final questionId = question.hashCode.toString();

                    // Initialize the map structure if needed
                    if (!(_sectionAnswers[IELTSSection.speaking]!['part1']
                            as Map)
                        .containsKey(questionId)) {
                      (_sectionAnswers[IELTSSection.speaking]!['part1']
                              as Map)[questionId] =
                          '';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${entry.key + 1}. $question'),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Record audio
                              },
                              icon: const Icon(Icons.mic, color: Colors.red),
                            ),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText:
                                      'Transcribed answer (or type directly)',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                onChanged: (value) {
                                  setState(() {
                                    (_sectionAnswers[IELTSSection
                                                .speaking]!['part1']
                                            as Map)[questionId] =
                                        value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Part 2
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Part 2: Individual Long Turn',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Topic card
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content[1]['topics'][0]['description'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        ...content[1]['topics'][0]['points'].map((point) {
                          return Text('• $point');
                        }).toList(),
                        const SizedBox(height: 8.0),
                        const Text(
                          'You will have 1 minute to prepare before speaking for 1-2 minutes.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Timer and recording UI
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Start recording
                        },
                        icon: const Icon(Icons.mic),
                        label: const Text('Record Answer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      const Text('00:00'), // Recording timer
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Transcription field
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Transcribed answer (or type directly)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        _sectionAnswers[IELTSSection.speaking]!['part2'] =
                            value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Part 3
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Part 3: Two-way Discussion',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ...content[2]['topics'][0]['questions'].asMap().entries.map((
                    entry,
                  ) {
                    final question = entry.value as String;
                    final questionId = question.hashCode.toString();

                    // Initialize the map structure if needed
                    if (!(_sectionAnswers[IELTSSection.speaking]!['part3']
                            as Map)
                        .containsKey(questionId)) {
                      (_sectionAnswers[IELTSSection.speaking]!['part3']
                              as Map)[questionId] =
                          '';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${entry.key + 1}. $question'),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Record audio
                              },
                              icon: const Icon(Icons.mic, color: Colors.red),
                            ),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText:
                                      'Transcribed answer (or type directly)',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                onChanged: (value) {
                                  setState(() {
                                    (_sectionAnswers[IELTSSection
                                                .speaking]!['part3']
                                            as Map)[questionId] =
                                        value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format seconds as mm:ss
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Count words in a string
  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
