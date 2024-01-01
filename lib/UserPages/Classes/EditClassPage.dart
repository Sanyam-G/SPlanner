import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'class_model.dart';

class EditClassPage extends StatefulWidget {
  final ClassModel classModel;

  EditClassPage({required this.classModel});

  @override
  _EditClassPageState createState() => _EditClassPageState();
}

class _EditClassPageState extends State<EditClassPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _roomNumberController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedDay;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.classModel.title;
    _roomNumberController.text = widget.classModel.room.toString();
    _startTime = widget.classModel.startTime;
    _endTime = widget.classModel.endTime;
    _selectedDay = widget.classModel.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Class'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Class Title'),
                ),
                TextFormField(
                  controller: _roomNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Room Number'),
                ),
                ListTile(
                  title: Text(_startTime == null
                      ? 'Select Start Time'
                      : 'Start Time: ${_startTime!.format(context)}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _startTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _startTime = pickedTime;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text(_endTime == null
                      ? 'Select End Time'
                      : 'End Time: ${_endTime!.format(context)}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _endTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _endTime = pickedTime;
                      });
                    }
                  },
                ),
                DropdownButton<String>(
                  value: _selectedDay,
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
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDay = newValue!;
                    });
                  },
                  hint: Text('Select Day'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String title = _titleController.text.trim();
                    int roomNumber =
                        int.tryParse(_roomNumberController.text) ?? 0;
                    if (title.isNotEmpty &&
                        _startTime != null &&
                        _endTime != null &&
                        _selectedDay != null &&
                        roomNumber != 0) {
                      ClassModel updatedClass = ClassModel(
                        id: widget.classModel.id, // Use the existing class id
                        title: title,
                        startTime: _startTime!,
                        endTime: _endTime!,
                        day: _selectedDay!,
                        room: roomNumber,
                      );
                      // Update class in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('classes')
                          .doc(updatedClass.id) // Use the updated class id
                          .update(updatedClass.toMap());

                      // Go back to the previous screen
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all the fields.'),
                        ),
                      );
                    }
                  },
                  child: Text('Update Class'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
