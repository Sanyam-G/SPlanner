import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/UserPages/ToDo/ToDo.dart';

class EditToDoPage extends StatefulWidget {
  final String uid;
  final ToDo todo;
  final int todoIndex;

  EditToDoPage({required this.uid, required this.todo, required this.todoIndex});

  @override
  _EditToDoPageState createState() => _EditToDoPageState();
}

class _EditToDoPageState extends State<EditToDoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.todo.title;
    _descriptionController.text = widget.todo.description;
    _selectedDateTime = widget.todo.dueDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit To-Do Item'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectDateAndTime,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Due date and time'),
                    Text(DateFormat('MMM d, yyyy, hh:mm a').format(
                        _selectedDateTime)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _editTodo,
                  child: const Text('Save'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateAndTime() async {
    final newDateTime = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.fromMillisecondsSinceEpoch(10000),
      lastDate: DateTime(2100),
    );
    if (newDateTime != null) {
      final newTimeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (newTimeOfDay != null) {
        setState(() {
          _selectedDateTime = DateTime(
            newDateTime.year,
            newDateTime.month,
            newDateTime.day,
            newTimeOfDay.hour,
            newTimeOfDay.minute,
          );
        });
      }
    }
  }

  void _editTodo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final userRef = FirebaseFirestore.instance.collection('users').doc(
          widget.uid);
      final todosRef = userRef.collection('todos');
      final snapshot = await todosRef.get();
      final docId = snapshot.docs[widget.todoIndex].id;
      await todosRef.doc(docId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dueDateTime': _selectedDateTime,
      });
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }
}
