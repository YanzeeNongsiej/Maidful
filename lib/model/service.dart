class Service {
  final List<String> days;
  final String rate;
  final String schedule;
  final List<String> services;
  final String time_from;
  final String time_to;
  final String userid;
  final String wage;
  final List<String> work_history;

  Service(
      {required this.days,
      required this.rate,
      required this.schedule,
      required this.services,
      required this.time_from,
      required this.time_to,
      required this.userid,
      required this.wage,
      required this.work_history});

  Map<String, dynamic> toMap() {
    return {
      'days': days,
      'rate': rate,
      'schedule': schedule,
      'services': services,
      'time_from': time_from,
      'time_to': time_to,
      'userid': userid,
      'wage': wage,
      'work_history': work_history,
    };
  }
}
