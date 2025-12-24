class AttendanceModel {
  final int id;
  final int userId;
  final String date;
  final String? punchIn;
  final String? punchOut;
  final String status; // Present, Absent, Half Day, Holiday
  final String? totalHours;
  final String? breakTime;
  final bool isLate;
  final bool isEarlyLeave;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    this.punchIn,
    this.punchOut,
    required this.status,
    this.totalHours,
    this.breakTime,
    this.isLate = false,
    this.isEarlyLeave = false,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      date: json['date'] ?? '',
      punchIn: json['punch_in'],
      punchOut: json['punch_out'],
      status: json['status'] ?? 'Absent',
      totalHours: json['total_hours'],
      breakTime: json['break_time'],
      isLate: json['is_late'] ?? false,
      isEarlyLeave: json['is_early_leave'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'punch_in': punchIn,
      'punch_out': punchOut,
      'status': status,
      'total_hours': totalHours,
      'break_time': breakTime,
      'is_late': isLate,
      'is_early_leave': isEarlyLeave,
    };
  }
}
