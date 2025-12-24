class LeaveModel {
  final int? id;
  final String leaveType; // 'Sick', 'Casual', 'Earned', etc.
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final bool isHalfDay;
  final String? halfDayType; // 'First Half', 'Second Half'
  final String employeeName; // For Admin/Manager view

  LeaveModel({
    this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = 'Pending',
    this.isHalfDay = false,
    this.halfDayType,
    this.employeeName = '',
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'],
      leaveType: json['leave_type'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      isHalfDay: json['is_half_day'] ?? false,
      halfDayType: json['half_day_type'],
      employeeName: json['employee_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leave_type': leaveType,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'reason': reason,
      'status': status,
      'is_half_day': isHalfDay,
      'half_day_type': halfDayType,
    };
  }
}
