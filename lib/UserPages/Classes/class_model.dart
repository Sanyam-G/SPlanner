import 'package:flutter/material.dart';
import 'dart:core';


class ClassModel {
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String day;
  final int room;
  final String id;

  ClassModel({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.room,
    required this.id
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'startTime': startTime.toString().substring(10, 15),
      'endTime': endTime.toString().substring(10, 15),
      'day': day,
      'room': room,
    };
  }

  static ClassModel fromMap(Map<String, dynamic> data, String id) {
    return ClassModel(
      title: data['title'],
      startTime: TimeOfDay(
          hour: int.parse(data['startTime'].split(':')[0]),
          minute: int.parse(data['startTime'].split(':')[1])),
      endTime: TimeOfDay(
          hour: int.parse(data['endTime'].split(':')[0]),
          minute: int.parse(data['endTime'].split(':')[1])),
      day: data['day'],
      room: data['room'],
      id: id,
    );
  }
}
