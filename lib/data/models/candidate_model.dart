class CandidateModel {
  final int id;
  final int jobPostingId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String appliedDate;
  final String? resumeUrl;
  final String? status;

  CandidateModel({
    required this.id,
    required this.jobPostingId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.appliedDate,
    this.resumeUrl,
    this.status,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'],
      jobPostingId: json['job_posting_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      appliedDate: json['applied_date'],
      resumeUrl: json['resume_url'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_posting_id': jobPostingId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'applied_date': appliedDate,
      'resume_url': resumeUrl,
      'status': status,
    };
  }
  
  String get fullName => '$firstName $lastName';
}
