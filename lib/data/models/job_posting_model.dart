class JobPostingModel {
  final int id;
  final int jobDescriptionId;
  final int numberOfPositions;
  final String employmentType;
  final String location;
  final int? salary;
  final String postingDate;
  final String? closingDate;
  final String approvalStatus;
  
  // Flattened field for convenience if backend returns it or we join it manually, 
  // currently Schema doesn't list 'title' directly unless we fetch it.
  // Actually, wait - let's look at schema logic. JobPostingResponse has simple fields. 
  // It doesn't look like it embeds JobDescription objects by default in the "Response" model 
  // UNLESS `model_config = "from_attributes": True` and SQLAlchemy relationship lazy loads it 
  // but Pydantic won't serialize it unless defined.
  // The backend route `get_all_job_postings` returns `JobPostingResponse`.
  // `JobPostingResponse` extends `JobPostingBase` which has `job_description_id`.
  // It does NOT have a `job_description` nested object.
  // So the frontend will need to fetch JobDescriptions to map ID to Title, 
  // OR the backend needs update. 
  // However, I see `admin_dashboard` method constructs a custom dictionary with title.
  // For standard CRUD, I might just have ID.
  // Ideally, I should update backend to include title, but I must work with what I have or request changes.
  // I'll stick to ID for now and fetch descriptions separately or just use ID. 
  // Actually, for a list screen, ID is useless. 
  // Let's assume I might need to fetch job descriptions to show titles.
  // WAIT: I can add `title` to the frontend model and try to populate it if I modify the backend or join on frontend.
  // For now, I'll stick to strict schema.

  JobPostingModel({
    required this.id,
    required this.jobDescriptionId,
    required this.numberOfPositions,
    required this.employmentType,
    required this.location,
    this.salary,
    required this.postingDate,
    this.closingDate,
    required this.approvalStatus,
  });

  factory JobPostingModel.fromJson(Map<String, dynamic> json) {
    return JobPostingModel(
      id: json['id'],
      jobDescriptionId: json['job_description_id'],
      numberOfPositions: json['number_of_positions'],
      employmentType: json['employment_type'],
      location: json['location'],
      salary: json['salary'],
      postingDate: json['posting_date'], // date string YYYY-MM-DD
      closingDate: json['closing_date'],
      approvalStatus: json['approval_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_description_id': jobDescriptionId,
      'number_of_positions': numberOfPositions,
      'employment_type': employmentType,
      'location': location,
      'salary': salary,
      'posting_date': postingDate,
      'closing_date': closingDate,
      'approval_status': approvalStatus,
    };
  }
}
