/// A single examination ("Final Term Examination", etc.).
class Exam {
  const Exam({
    required this.id,
    required this.name,
    this.type,
    this.status,
    this.startsOn,
    this.endsOn,
    this.term,
  });

  final String id;
  final String name;
  final String? type;
  final String? status;
  final String? startsOn;
  final String? endsOn;
  final String? term;

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['examName']?.toString() ?? '',
      type: json['type']?.toString(),
      status: json['status']?.toString(),
      startsOn: json['startDate']?.toString() ?? json['startsOn']?.toString(),
      endsOn: json['endDate']?.toString() ?? json['endsOn']?.toString(),
      term: json['term']?.toString(),
    );
  }
}

/// A single datesheet entry (an exam paper scheduled for a class).
class DateSheet {
  const DateSheet({
    required this.id,
    this.title,
    this.examName,
    this.className,
    this.subjectName,
    this.date,
    this.startTime,
    this.endTime,
    this.room,
    this.pdfUrl,
  });

  final String id;
  final String? title;
  final String? examName;
  final String? className;
  final String? subjectName;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? room;
  final String? pdfUrl;

  factory DateSheet.fromJson(Map<String, dynamic> json) {
    return DateSheet(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      examName: json['examName']?.toString() ?? json['exam_name']?.toString(),
      className: json['className']?.toString(),
      subjectName: json['subjectName']?.toString() ?? json['subject']?.toString(),
      date: json['date']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      room: json['room']?.toString(),
      pdfUrl: json['pdfUrl']?.toString() ?? json['pdf_url']?.toString(),
    );
  }
}

/// View-model for the Exams tab: active / upcoming / completed lists.
class ExamOverview {
  const ExamOverview({
    this.active = const [],
    this.upcoming = const [],
    this.completed = const [],
    this.datesheets = const [],
  });

  final List<Exam> active;
  final List<Exam> upcoming;
  final List<Exam> completed;
  final List<DateSheet> datesheets;

  bool get isEmpty => active.isEmpty && upcoming.isEmpty && completed.isEmpty;
}