class Enrollment {
  final int? id;
  final int userId;
  final int programId;
  final String name;
  final String email;
  final String interest;
  final String status;

  Enrollment({
    this.id,
    required this.userId,
    required this.programId,
    required this.name,
    required this.email,
    required this.interest,
    this.status = 'ENROLLED',
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] != null
          ? (json['id'] is int ? json['id'] : int.parse(json['id'].toString()))
          : null,
      userId: json['userId'] is int
          ? json['userId']
          : int.parse(json['userId'].toString()),
      programId: json['programId'] is int
          ? json['programId']
          : int.parse(json['programId'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      interest: json['interest'] ?? '',
      status: json['status'] ?? 'ENROLLED',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'userId': userId,
    'programId': programId,
    'name': name,
    'email': email,
    'interest': interest,
    'status': status,
  };
}
