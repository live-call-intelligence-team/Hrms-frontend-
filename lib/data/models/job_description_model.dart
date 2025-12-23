class JobDescriptionModel {
  final int id;
  final String title;
  final String? description;
  final String? requiredSkills;

  JobDescriptionModel({
    required this.id,
    required this.title,
    this.description,
    this.requiredSkills,
  });

  factory JobDescriptionModel.fromJson(Map<String, dynamic> json) {
    return JobDescriptionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      requiredSkills: json['required_skills'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'required_skills': requiredSkills,
    };
  }
}
