/// Service for generating authentic IELTS Speaking Test questions
import 'dart:math';
import '../models/ielts_speaking_test_models.dart';

class IELTSSpeakingQuestionBank {
  static final Random _random = Random();

  /// Generate questions based on test duration
  static List<SpeakingQuestion> generateTest(SpeakingTestDuration duration) {
    final questions = <SpeakingQuestion>[];

    switch (duration) {
      case SpeakingTestDuration.short:
        // Only Part 1 (5 minutes)
        questions.addAll(_generatePart1Questions(count: 6));
        break;

      case SpeakingTestDuration.medium:
        // Part 1 + Part 2 (10 minutes)
        questions.addAll(_generatePart1Questions(count: 4));
        questions.add(_generatePart2Question());
        break;

      case SpeakingTestDuration.full:
        // Complete test: Part 1 + Part 2 + Part 3 (15 minutes)
        questions.addAll(_generatePart1Questions(count: 4));
        questions.add(_generatePart2Question());
        questions.addAll(_generatePart3Questions(count: 4));
        break;
    }

    return questions;
  }

  /// Generate Part 1 questions (Introduction & Interview)
  static List<SpeakingQuestion> _generatePart1Questions({int count = 4}) {
    final topics = [
      _part1Home,
      _part1Work,
      _part1Studies,
      _part1Hobbies,
      _part1Family,
      _part1Travel,
      _part1Food,
      _part1Technology,
    ];

    final selectedTopic = topics[_random.nextInt(topics.length)];
    final selectedQuestions = <SpeakingQuestion>[];

    // Shuffle and take the required count
    selectedTopic.shuffle(_random);
    for (var i = 0; i < min(count, selectedTopic.length); i++) {
      selectedQuestions.add(
        SpeakingQuestion(
          part: SpeakingTestPart.part1,
          question: selectedTopic[i],
          speakingTimeSeconds: 30, // 30 seconds per Part 1 answer
        ),
      );
    }

    return selectedQuestions;
  }

  /// Generate Part 2 question (Cue Card)
  static SpeakingQuestion _generatePart2Question() {
    final cueCards = _part2CueCards;
    final selected = cueCards[_random.nextInt(cueCards.length)];

    return SpeakingQuestion(
      part: SpeakingTestPart.part2,
      question: selected['topic']!,
      bulletPoints: List<String>.from(selected['points']!),
      preparationTimeSeconds: 60, // 1 minute preparation
      speakingTimeSeconds: 120, // 2 minutes speaking
    );
  }

  /// Generate Part 3 questions (Two-way Discussion)
  static List<SpeakingQuestion> _generatePart3Questions({int count = 4}) {
    final topics = [
      _part3Education,
      _part3Technology,
      _part3Society,
      _part3Environment,
      _part3Culture,
      _part3Economy,
    ];

    final selectedTopic = topics[_random.nextInt(topics.length)];
    final selectedQuestions = <SpeakingQuestion>[];

    selectedTopic.shuffle(_random);
    for (var i = 0; i < min(count, selectedTopic.length); i++) {
      selectedQuestions.add(
        SpeakingQuestion(
          part: SpeakingTestPart.part3,
          question: selectedTopic[i],
          speakingTimeSeconds: 60, // 1 minute per Part 3 answer
        ),
      );
    }

    return selectedQuestions;
  }

  // Part 1 Question Banks
  static final List<String> _part1Home = [
    "Do you live in a house or an apartment?",
    "What do you like most about your home?",
    "What would you like to change about your home?",
    "How long have you lived there?",
    "What's your favorite room in your home?",
    "Do you prefer living in a house or an apartment? Why?",
  ];

  static final List<String> _part1Work = [
    "What do you do? Do you work or are you a student?",
    "Why did you choose this job/field of study?",
    "What do you find most interesting about your work/studies?",
    "What are your responsibilities at work?",
    "Do you enjoy your current job/studies? Why or why not?",
    "What would be your ideal job?",
  ];

  static final List<String> _part1Studies = [
    "What subject are you studying?",
    "Why did you choose to study this subject?",
    "What do you find most interesting about your studies?",
    "Do you prefer studying alone or with others?",
    "What are your future career plans?",
    "How do you usually prepare for exams?",
  ];

  static final List<String> _part1Hobbies = [
    "What do you like to do in your free time?",
    "How long have you had this hobby?",
    "Is it a popular hobby in your country?",
    "Would you like to try any new hobbies in the future?",
    "Do you prefer indoor or outdoor activities?",
    "How often do you practice your hobby?",
  ];

  static final List<String> _part1Family = [
    "Can you tell me about your family?",
    "Who are you closest to in your family?",
    "How much time do you spend with your family?",
    "What activities do you do together as a family?",
    "Are family relationships important in your country?",
    "How has your family influenced you?",
  ];

  static final List<String> _part1Travel = [
    "Do you like traveling?",
    "What places have you traveled to?",
    "What's your favorite place you've visited? Why?",
    "Do you prefer traveling alone or with others?",
    "What kind of places would you like to visit in the future?",
    "How do you usually plan your trips?",
  ];

  static final List<String> _part1Food = [
    "What's your favorite food?",
    "Do you enjoy cooking? Why or why not?",
    "What kind of food is popular in your country?",
    "Have you ever tried foreign cuisine?",
    "Do you prefer eating at home or in restaurants?",
    "How often do you eat out with friends or family?",
  ];

  static final List<String> _part1Technology = [
    "How often do you use technology?",
    "What technological device do you use most?",
    "How has technology changed your daily life?",
    "Do you think technology makes life easier or more complicated?",
    "What new technology would you like to learn about?",
    "Do you prefer online or in-person communication?",
  ];

  // Part 2 Cue Cards
  static final List<Map<String, dynamic>> _part2CueCards = [
    {
      'topic': 'Describe a person who has influenced you',
      'points': [
        'Who this person is',
        'How you know this person',
        'What influence this person has had on you',
        'And explain why this person is important to you',
      ],
    },
    {
      'topic': 'Describe a memorable journey you have made',
      'points': [
        'Where you went',
        'Who you went with',
        'What you did during this journey',
        'And explain why this journey was memorable',
      ],
    },
    {
      'topic': 'Describe a skill you would like to learn',
      'points': [
        'What the skill is',
        'Why you want to learn it',
        'How you plan to learn it',
        'And explain how this skill would benefit you',
      ],
    },
    {
      'topic': 'Describe a book that had a significant impact on you',
      'points': [
        'What the book is about',
        'When you read it',
        'What you learned from it',
        'And explain why it had such an impact',
      ],
    },
    {
      'topic': 'Describe an important decision you have made',
      'points': [
        'What the decision was',
        'When you made it',
        'What factors influenced your decision',
        'And explain the result of this decision',
      ],
    },
    {
      'topic': 'Describe a place you would like to visit',
      'points': [
        'Where this place is',
        'What you know about it',
        'What you would do there',
        'And explain why you want to visit this place',
      ],
    },
    {
      'topic': 'Describe a hobby or interest you have',
      'points': [
        'What the hobby is',
        'When you started it',
        'How often you do it',
        'And explain why you enjoy this hobby',
      ],
    },
    {
      'topic': 'Describe a challenge you have overcome',
      'points': [
        'What the challenge was',
        'When you faced it',
        'How you overcame it',
        'And explain what you learned from this experience',
      ],
    },
  ];

  // Part 3 Question Banks
  static final List<String> _part3Education = [
    "How has education changed in your country over the past few decades?",
    "Do you think traditional classroom learning will be replaced by online education?",
    "What role should governments play in education?",
    "How important is higher education for career success?",
    "Should education focus more on practical skills or theoretical knowledge?",
    "What are the advantages and disadvantages of studying abroad?",
  ];

  static final List<String> _part3Technology = [
    "How has technology changed the way people communicate?",
    "What impact has social media had on society?",
    "Do you think artificial intelligence will replace human workers?",
    "How can technology be used to solve environmental problems?",
    "What are the potential dangers of becoming too dependent on technology?",
    "How might technology change education in the future?",
  ];

  static final List<String> _part3Society = [
    "What are the biggest challenges facing society today?",
    "How has the role of family changed in modern society?",
    "Do you think people are becoming more individualistic?",
    "What can be done to reduce social inequality?",
    "How important is community involvement in modern life?",
    "What role should governments play in social welfare?",
  ];

  static final List<String> _part3Environment = [
    "What are the most serious environmental problems today?",
    "Who should be responsible for protecting the environment - individuals or governments?",
    "How can we encourage people to be more environmentally friendly?",
    "Do you think renewable energy will replace fossil fuels?",
    "What impact does climate change have on people's daily lives?",
    "How can businesses balance profit with environmental responsibility?",
  ];

  static final List<String> _part3Culture = [
    "How important is it to preserve traditional cultures?",
    "What impact does globalization have on local cultures?",
    "Should countries promote their cultural heritage to tourists?",
    "How has technology affected cultural traditions?",
    "What are the benefits of cultural diversity?",
    "How can different cultures coexist peacefully?",
  ];

  static final List<String> _part3Economy = [
    "What factors contribute to a country's economic success?",
    "How has globalization affected world economies?",
    "Should governments provide financial support to struggling businesses?",
    "What role does entrepreneurship play in economic development?",
    "How important is international trade for a country's economy?",
    "What impact do economic recessions have on society?",
  ];
}
