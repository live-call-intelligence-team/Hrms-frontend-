class Shift {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final String breakDuration; // e.g., "01:00:00"
  final String totalHours;
  final String description;
  final bool isActive;
  final int? employeeCount;

  Shift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.breakDuration,
    required this.totalHours,
    this.description = '',
    this.isActive = true,
    this.employeeCount,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      breakDuration: json['break_duration'] ?? '00:00:00',
      totalHours: json['total_hours'] ?? '00:00:00',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
      employeeCount: json['employee_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'break_duration': breakDuration,
      'total_hours': totalHours,
      'description': description,
      'is_active': isActive,
    };
  }
}

class ShiftRoster {
  final int id;
  final String name;
  final String effectiveDate;
  final int employeeCount;
  final String status;
  // Add more fields as per API details if needed (e.g., weekly schedule details)

  ShiftRoster({
    required this.id,
    required this.name,
    required this.effectiveDate,
    required this.employeeCount,
    required this.status,
  });

  factory ShiftRoster.fromJson(Map<String, dynamic> json) {
    return ShiftRoster(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      effectiveDate: json['effective_date'] ?? '',
      employeeCount: json['employee_count'] ?? 0,
      status: json['status'] ?? 'Draft',
    );
  }
}

class UserShift {
  final int id;
  final String date;
  final Shift? shift;
  final String type; // e.g., "Shift", "Off", "Holiday"

  UserShift({
    required this.id,
    required this.date,
    this.shift,
    required this.type,
  });

  factory UserShift.fromJson(Map<String, dynamic> json) {
    return UserShift(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      shift: json['shift'] != null ? Shift.fromJson(json['shift']) : null,
      type: json['type'] ?? 'Shift',
    );
  }
}

class ShiftChangeRequest {
  final int id;
  final int userId;
  final String userName;
  final String currentShiftDate;
  final String currentShiftName;
  final String requestedShiftName;
  final String reason;
  final String status; // Pending, Approved, Rejected

  ShiftChangeRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.currentShiftDate,
    required this.currentShiftName,
    required this.requestedShiftName,
    required this.reason,
    required this.status,
  });

  factory ShiftChangeRequest.fromJson(Map<String, dynamic> json) {
    return ShiftChangeRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Unknown',
      currentShiftDate: json['current_shift_date'] ?? '',
      currentShiftName: json['current_shift_name'] ?? '',
      requestedShiftName: json['requested_shift_name'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
     return {
       'current_shift_date': currentShiftDate,
       // Assuming IDs are sent for shifts usually, but keeping names as per UI req for now or mixed
       'requested_shift_id': 0, // Placeholder, would need logic to map
       'reason': reason,
     };
  }
}

class ShiftSummary {
  final int totalShifts;
  final int totalEmployees;
  final List<ShiftDistribution> distribution;
  final List<ShiftReportItem> report;

  ShiftSummary({
    required this.totalShifts,
    required this.totalEmployees,
    required this.distribution,
    required this.report,
  });

  factory ShiftSummary.fromJson(Map<String, dynamic> json) {
    return ShiftSummary(
      totalShifts: json['total_shifts'] ?? 0,
      totalEmployees: json['total_employees'] ?? 0,
      distribution: (json['distribution'] as List?)
              ?.map((e) => ShiftDistribution.fromJson(e))
              .toList() ??
          [],
      report: (json['report'] as List?)
              ?.map((e) => ShiftReportItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ShiftDistribution {
  final String shiftName;
  final int count;

  ShiftDistribution({required this.shiftName, required this.count});

  factory ShiftDistribution.fromJson(Map<String, dynamic> json) {
    return ShiftDistribution(
      shiftName: json['shift_name'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ShiftReportItem {
  final String shiftName;
  final int employeeCount;
  final String avgHours;
  final double coveragePercent;

  ShiftReportItem({
    required this.shiftName,
    required this.employeeCount,
    required this.avgHours,
    required this.coveragePercent,
  });

  factory ShiftReportItem.fromJson(Map<String, dynamic> json) {
    return ShiftReportItem(
      shiftName: json['shift_name'] ?? '',
      employeeCount: json['employee_count'] ?? 0,
      avgHours: json['avg_hours'] ?? '00:00',
      coveragePercent: (json['coverage_percent'] ?? 0).toDouble(),
    );
  }
}
