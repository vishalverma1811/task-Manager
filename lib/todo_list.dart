import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/task_detail_screen.dart';
import 'core/model/task_model.dart';
import 'core/provider/task_provider.dart';
import 'main.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Task> tasks = [];
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? selectedDate;
  String priority = 'Low';
  bool status = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    tasks = tasksBox.values.toList();
  }

  // State variable for current filter
  String currentFilter = 'all';

// Method to filter tasks based on selected filter
  List<Task> _filterTasks(List<Task> tasks) {
    switch (currentFilter) {
      case 'complete':
        return tasks.where((task) => task.status).toList();
      case 'pending':
        return tasks.where((task) => !task.status).toList();
      default:
        return tasks; // Show all tasks if no filter is applied
    }
  }

// Method to set the current filter based on selected value
  void filterTasks(String value) {
    currentFilter = value;
  }

  void _showStatusSnackBar(bool status) {
    final snackBar = SnackBar(
      content: Text(
        status ? 'Task marked complete' : 'Task marked incomplete',
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: status ? Colors.lightGreen : Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager App'),
        elevation: 5,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                filterTasks(value);
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'all',
                  child: Text('All Tasks'),
                ),
                const PopupMenuItem<String>(
                  value: 'complete',
                  child: Text('Complete Tasks'),
                ),
                const PopupMenuItem<String>(
                  value: 'pending',
                  child: Text('Pending Tasks'),
                ),
              ];
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: tasks.isEmpty
            ? const Center(child: Text('No Task Available'))
            : FutureBuilder<List<Task>>(
                future: TaskProvider().loadTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading tasks'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Task Available'));
                  } else {
                    // Use the filtered tasks here
                    final filteredTasks = _filterTasks(snapshot.data!);
                    return ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Card(
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Text(task.priority),
                            onTap: () {
                              // Navigate to TaskDetailScreen on tap
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskDetailScreen(
                                    task: task,
                                    taskIndex: index,
                                  ),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: task.status,
                                  onChanged: (value) {
                                    setState(() {
                                      task.status = value!;
                                      TaskProvider().updateTask(index, task);
                                    });
                                    _showStatusSnackBar(task.status);
                                  },
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      TaskProvider().deleteTask(index);
                                      fetchData(); // Reload the task list
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTask(); // Function to add a new task
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addTask() async {
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Deadline',
                            hintText: 'Select a date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                                _dateController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          value: priority,
                          items: ['Low', 'Medium', 'High']
                              .map((priorityValue) => DropdownMenuItem(
                                    value: priorityValue,
                                    child: Text(priorityValue),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            priority = value!;
                          },
                          decoration: const InputDecoration(labelText: 'Priority'),
                          validator: (value) {
                            if (value == null) {
                              return 'Priority is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Text('Mark Complete'),
                            Checkbox(
                              value: status,
                              onChanged: (value) {
                                setState(() {
                                  status = value!; // Update status
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newTask = Task(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    deadline: selectedDate!,
                    priority: priority,
                    status: status,
                  );
                  await tasksBox.add(newTask);
                  await TaskProvider().loadTasks();
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TodoList()),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
