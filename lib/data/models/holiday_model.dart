class HolidayModel {
  final int? id;
  final String name;
  final DateTime date;
  final String type; // 'National', 'Restricted', etc.
  final String? description;

  HolidayModel({
    this.id,
    required this.name,
    required this.date,
    required this.type,
    this.description,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id'],
      name: json['name'] ?? '',
      date: DateTime.parse(json['date']),
      type: json['type'] ?? 'Regular',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'date': date.toIso8601String().split('T')[0],
      'type': type,
      'description': description,
    };
  }
}
