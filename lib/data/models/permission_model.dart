import 'package:flutter/material.dart';

class PermissionModel {
  final int? id;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String type; // 'Late Arrival', 'Early Exit', 'Personal Work'
  final String employeeName;

  PermissionModel({
    this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.type,
    this.status = 'Pending',
    this.employeeName = '',
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: _parseTime(json['start_time']),
      endTime: _parseTime(json['end_time']),
      reason: json['reason'] ?? '',
      type: json['type'] ?? 'General',
      status: json['status'] ?? 'Pending',
      employeeName: json['employee_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'start_time': _formatTime(startTime),
      'end_time': _formatTime(endTime),
      'reason': reason,
      'type': type,
    };
  }

  static TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  String get durationString {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final diff = endMinutes - startMinutes;
    final hours = diff ~/ 60;
    final minutes = diff % 60;
    return '${hours}h ${minutes}m';
  }
}
