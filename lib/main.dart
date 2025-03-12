import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

void main() {
  runApp(TaskManagerApp(isDarkMode: false)); // Pass default value
}

class TaskManagerApp extends StatelessWidget {
  final bool isDarkMode; // Add this line

  TaskManagerApp({required this.isDarkMode}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: isDarkMode ? Colors.deepPurple : Colors.indigo,
      ),
      home: TaskManagerHome(),
    );
  }
}

class TaskManagerHome extends StatefulWidget {
  @override
  _TaskManagerHomeState createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends State<TaskManagerHome> {
  bool isDarkMode = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();
  Map<String, List<String>> _tasks = {};

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadTasks();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = prefs.getBool('isDarkMode') ?? false);
  }

  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = !isDarkMode;
      prefs.setBool('isDarkMode', isDarkMode);
    });
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? taskData = prefs.getString('tasks');
    if (taskData != null) {
      setState(() => _tasks = Map<String, List<String>>.from(jsonDecode(taskData)));
    }
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(_tasks));
  }

  void _addTask(String task) {
    String key = _formatDate(_selectedDate);
    setState(() {
      _tasks.putIfAbsent(key, () => []).add(task);
      _saveTasks();
    });
  }

  void _editTask(int index, String updatedTask) {
    String key = _formatDate(_selectedDate);
    setState(() {
      _tasks[key]![index] = updatedTask;
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    String key = _formatDate(_selectedDate);
    setState(() {
      _tasks[key]!.removeAt(index);
      if (_tasks[key]!.isEmpty) _tasks.remove(key);
      _saveTasks();
    });
  }

  void _showTaskDialog({String? task, int? index}) {
    TextEditingController _controller = TextEditingController(text: task);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(task == null ? "Add Task" : "Edit Task"),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: "Enter task"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                task == null
                    ? _addTask(_controller.text.trim())
                    : _editTask(index!, _controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  List<String> _getTasksForDay(DateTime date) {
    String key = _formatDate(date);
    return _tasks[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager"),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showTaskDialog(),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onFormatChanged: (format) {}, // Add this line to handle format changes

            onDaySelected: (selectedDay, _) => setState(() => _selectedDate = selectedDay),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _getTasksForDay(_selectedDate).length,
              itemBuilder: (context, index) {
                String task = _getTasksForDay(_selectedDate)[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    title: Text(task, style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showTaskDialog(task: task, index: index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
