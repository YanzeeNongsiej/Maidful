class Service {
  final List<String> days;

  final List<bool> schedule;
  final Map<String, List<String>> services;
  final List<String> timing;
  final String userid;
  final String nego;
  final List<String> work_history;
  final bool ack;
  final String remarks;
  Service(
      {required this.nego,
      required this.days,
      required this.schedule,
      required this.services,
      required this.timing,
      required this.userid,
      required this.work_history,
      required this.ack,
      required this.remarks});

  Map<String, dynamic> toMap() {
    return {
      'days': days,
      'schedule': schedule,
      'services': services,
      'timing': timing,
      'userid': userid,
      'work_history': work_history,
      'ack': ack,
      'nego': nego,
      'remarks': remarks
    };
  }
}
