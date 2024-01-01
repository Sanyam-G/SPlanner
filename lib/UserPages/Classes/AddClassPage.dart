import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/UserPages/Classes/class_model.dart';

class AddClassPage extends StatefulWidget {
  @override
  _AddClassPageState createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  TimeOfDay _startTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 9, minute: 0);
  String _day = 'Monday';
  int _room = 1;

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Class'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Class Title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a class title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                ),
                Row(
                  children: [
                    Text('Start Time: ${_startTime.format(context)}'),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );

                        if (selectedTime != null) {
                          setState(() {
                            _startTime = selectedTime;
                          });
                        }
                      },
                      child: Text('Select Start Time'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('End Time: ${_endTime.format(context)}'),
                    Spacer(),
                    TextButton(
                      onPressed: () async {
                        TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );

                        if (selectedTime != null) {
                          setState(() {
                            _endTime = selectedTime;
                          });
                        }
                      },
                      child: Text('Select End Time'),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _day,
                  onChanged: (String? newValue) {
                    setState(() {
                      _day = newValue!;
                    });
                  },
                  items: [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Class Room Number',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a class room number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _room = int.parse(value!);
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ClassModel newClass = ClassModel(
                        id: '', // Provide an empty string, since it is auto-generated later
                        title: _title,
                        startTime: _startTime,
                        endTime: _endTime,
                        day: _day,
                        room: _room,
                      );

                      // Add the created class to Firestore and update the 'id' field with the document ID
                      DocumentReference docRef = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('classes')
                          .add(newClass.toMap());
                      await docRef.update({'id': docRef.id});

                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
