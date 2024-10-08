import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/todo_list.dart';
import 'core/model/task_model.dart';
import 'core/provider/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task; // Task to be displayed and edited
  final int taskIndex; // Index of the task in the list

  TaskDetailScreen({required this.task, required this.taskIndex});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  String priority = 'Low';
  DateTime? selectedDate;
  bool status = false;

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with task details
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.task.deadline),
    );
    priority = widget.task.priority;
    selectedDate = widget.task.deadline;
    status = widget.task.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessing TaskProvider via Provider.of()
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Task Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Task Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Task Date Field
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  hintText: 'Select a date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                validator: (value) {
                  if (selectedDate == null) {
                    return 'Date is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Priority Dropdown Field
              DropdownButtonFormField<String>(
                value: priority,
                items: ['Low', 'Medium', 'High']
                    .map((priorityValue) => DropdownMenuItem(
                  value: priorityValue,
                  child: Text(priorityValue),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Priority'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Priority is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Status Checkbox
              Row(
                children: [
                  const Text('Mark Complete'),
                  Checkbox(
                    value: status,
                    onChanged: (value) {
                      setState(() {
                        status = value!;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32.0),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Create an updated task object
                        Task updatedTask = Task(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          deadline: selectedDate!,
                          priority: priority,
                          status: status,
                        );

                        // Call the updateTask method from TaskProvider
                        taskProvider.updateTask(widget.taskIndex, updatedTask);

                        // Navigate back after update
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const TodoList()),
                        );
                      }
                    },
                    child: const Text('Update'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back without saving changes
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
