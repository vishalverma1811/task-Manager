import 'package:flutter/cupertino.dart';
import '../../main.dart';
import '../model/task_model.dart';

class TaskProvider with ChangeNotifier{
  List<Task> task = [];

  List<Task> get tasks => task;

  TaskProvider() {
    loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    try {
      task = tasksBox.values.toList();
      return task;
    } catch (error) {
      print('Error loading tasks: $error');
      return [];
    }
  }

  Future<void> updateTask(int index, Task updatedTask) async {
    try {

      await tasksBox.putAt(index, updatedTask);
      loadTasks();
    } catch (error) {
      print('Error updating task: $error');
    }
  }


  Future<void> deleteTask(int index) async {
    try {
      await tasksBox.deleteAt(index);
      await loadTasks();
    } catch (error) {
      print('Error deleting task: $error');
    }
  }
}