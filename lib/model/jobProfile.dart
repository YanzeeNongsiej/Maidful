class JobProfile {
  final List<String> days;

  final List<bool> schedule;
  final List<String> services;
  final List<String> timing;
  final String userid;
  final String nego;

  final bool ack;
  final String remarks;
  final List<String> imageUrl;
  JobProfile(
      {required this.nego,
      required this.days,
      required this.schedule,
      required this.services,
      required this.timing,
      required this.userid,
      required this.ack,
      required this.remarks,
      required this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      'days': days,
      'schedule': schedule,
      'services': services,
      'timing': timing,
      'userid': userid,
      'ack': ack,
      'nego': nego,
      'remarks': remarks,
      'imageurl': imageUrl
    };
  }
}
