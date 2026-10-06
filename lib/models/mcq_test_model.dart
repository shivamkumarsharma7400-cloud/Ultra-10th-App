class McqQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctOption;
  final String explanation;

  McqQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOption,
    this.explanation = '',
  });

  factory McqQuestion.fromFirestoreMap(Map<String, dynamic> map) {
    int idVal = 1;
    if (map['id'] != null) {
      if (map['id'] is Map) {
        idVal = int.tryParse(map['id']['integerValue']?.toString() ?? '1') ?? 1;
      } else {
        idVal = int.tryParse(map['id'].toString()) ?? 1;
      }
    }

    String qVal = '';
    if (map['question'] != null) {
      if (map['question'] is Map) {
        qVal = map['question']['stringValue'] ?? '';
      } else {
        qVal = map['question'].toString();
      }
    }

    int corrVal = 0;
    if (map['correctOption'] != null) {
      if (map['correctOption'] is Map) {
        corrVal = int.tryParse(map['correctOption']['integerValue']?.toString() ?? '0') ?? 0;
      } else {
        corrVal = int.tryParse(map['correctOption'].toString()) ?? 0;
      }
    }

    String explVal = '';
    if (map['explanation'] != null) {
      if (map['explanation'] is Map) {
        explVal = map['explanation']['stringValue'] ?? '';
      } else {
        explVal = map['explanation'].toString();
      }
    }

    List<String> opts = [];
    if (map['options'] != null) {
      if (map['options'] is Map && map['options']['arrayValue'] != null) {
        final vals = map['options']['arrayValue']['values'] as List? ?? [];
        for (var v in vals) {
          if (v is Map) {
            opts.add(v['stringValue']?.toString() ?? '');
          } else {
            opts.add(v.toString());
          }
        }
      } else if (map['options'] is List) {
        for (var o in map['options']) {
          opts.add(o.toString());
        }
      }
    }

    return McqQuestion(
      id: idVal,
      question: qVal,
      options: opts,
      correctOption: corrVal,
      explanation: explVal,
    );
  }
}

class McqTest {
  final String id;
  final String title;
  final String subject;
  final String chapter;
  final int durationMinutes;
  final List<McqQuestion> questions;
  final String createdAt;

  McqTest({
    required this.id,
    required this.title,
    required this.subject,
    required this.chapter,
    required this.durationMinutes,
    required this.questions,
    this.createdAt = '',
  });

  factory McqTest.fromFirestoreDoc(Map<String, dynamic> doc) {
    // doc['name'] = "projects/ultra-10th-a5611/databases/(default)/documents/mcq_tests/{id}"
    String docId = '';
    if (doc['name'] != null) {
      docId = (doc['name'] as String).split('/').last;
    }

    final fields = doc['fields'] as Map<String, dynamic>? ?? {};

    String tTitle = fields['title']?['stringValue'] ?? 'Practice Test';
    String tSubject = fields['subject']?['stringValue'] ?? 'Science';
    String tChapter = fields['chapter']?['stringValue'] ?? '';
    int tDuration = int.tryParse(fields['durationMinutes']?['integerValue']?.toString() ?? '20') ?? 20;
    String tCreated = fields['createdAt']?['timestampValue'] ?? '';

    List<McqQuestion> qList = [];
    final qValues = fields['questions']?['arrayValue']?['values'] as List? ?? [];
    for (var qItem in qValues) {
      if (qItem is Map && qItem['mapValue'] != null && qItem['mapValue']['fields'] != null) {
        qList.add(McqQuestion.fromFirestoreMap(Map<String, dynamic>.from(qItem['mapValue']['fields'] as Map)));
      } else if (qItem is Map) {
        qList.add(McqQuestion.fromFirestoreMap(Map<String, dynamic>.from(qItem)));
      }
    }

    return McqTest(
      id: docId,
      title: tTitle,
      subject: tSubject,
      chapter: tChapter,
      durationMinutes: tDuration,
      questions: qList,
      createdAt: tCreated,
    );
  }
}
