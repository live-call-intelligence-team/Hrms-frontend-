import 'course_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final List<CourseModel> courses;

  CategoryModel({
    required this.id,
    required this.name,
    this.courses = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var list = json['courses'] as List? ?? [];
    List<CourseModel> coursesList = list.map((i) => CourseModel.fromJson(i)).toList();

    return CategoryModel(
      id: json['id'],
      name: json['name'],
      courses: coursesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'courses': courses.map((x) => x.toJson()).toList(),
    };
  }
}
