class Service {
  final List<String> days;
  final String rate;
  final String schedule;
  final List<String> services;
  final Map<String, dynamic> timing;
  final String userid;
  final String wage;
  final List<String> work_history;
  final bool ack;

  Service(
      {required this.days,
      required this.rate,
      required this.schedule,
      required this.services,
      required this.timing,
      required this.userid,
      required this.wage,
      required this.work_history,
      required this.ack});

  Map<String, dynamic> toMap() {
    return {
      'days': days,
      'rate': rate,
      'schedule': schedule,
      'services': services,
      'timing': timing,
      'userid': userid,
      'wage': wage,
      'work_history': work_history,
      'ack': ack
    };
  }
}
