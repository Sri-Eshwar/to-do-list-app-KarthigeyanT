import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For date formatting

class TableCalendarWidget extends StatefulWidget {
  @override
  _TableCalendarWidgetState createState() => _TableCalendarWidgetState();
}

class _TableCalendarWidgetState extends State<TableCalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();
  Map<String, List<String>> _tasks = {}; // Store tasks with string keys
  TextEditingController _taskController = TextEditingController();

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        final dateKey = _formatDate(_selectedDate);
        _tasks[dateKey] = _tasks[dateKey] ?? [];
        _tasks[dateKey]!.add(_taskController.text);
      });
      _taskController.clear();
      Navigator.pop(context);
    }
  }

  void _editTask(int index) {
    final dateKey = _formatDate(_selectedDate);
    _taskController.text = _tasks[dateKey]![index];
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildTaskInputSheet(() {
        setState(() {
          _tasks[dateKey]![index] = _taskController.text;
        });
        _taskController.clear();
        Navigator.pop(context);
      }),
    );
  }

  void _deleteTask(int index) {
    final dateKey = _formatDate(_selectedDate);
    setState(() {
      _tasks[dateKey]!.removeAt(index);
      if (_tasks[dateKey]!.isEmpty) {
        _tasks.remove(dateKey);
      }
    });
  }

  Widget _buildTaskInputSheet(VoidCallback onSave) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(
              labelText: 'Enter task',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: onSave, child: Text('Save Task')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = _formatDate(_selectedDate);
    return Scaffold(
      appBar: AppBar(title: Text('Task Calendar')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) => _formatDate(day) == dateKey,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),
          Expanded(
            child: _tasks[dateKey]?.isEmpty ?? true
                ? Center(child: Text('No tasks for this day'))
                : ListView.builder(
                    itemCount: _tasks[dateKey]?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_tasks[dateKey]![index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editTask(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteTask(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (context) => _buildTaskInputSheet(_addTask),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
