import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime deadline;

  @HiveField(3)
  String priority; // Can be 'Low', 'Medium', 'High'

  @HiveField(4)
  bool status; // Can be true for Completed, false for Pending

  Task({
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      priority: json['priority'] ?? 'Low',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'status': status,
    };
  }
}
