import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/UserPages/ToDo/To-Do_List_Page.dart';
import 'package:intl/intl.dart';


class AddToDoPage extends StatefulWidget {

  @override
  _AddToDoPageState createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add To-Do Item'),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                      ),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _selectedDateTime = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      validator: (value) {
                        if (_selectedDateTime == null) {
                          return 'Please select a due date and time';
                        }
                        return null;
                      },
                      readOnly: true,
                      controller: TextEditingController(
                          text: _selectedDateTime == null
                              ? ''
                              : DateFormat.yMd().add_jm().format(_selectedDateTime!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Add'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTodo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      final userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final todosRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('todos');
      await todosRef.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
        'dueDateTime': _selectedDateTime, // Save selectedDateTime to Firestore
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ToDoListPage(uid: user.uid)));
    }
  }
}




