class Maid {
  final int id;
  final String name;
  final String address;

  Maid({required this.id, required this.name, required this.address});

  factory Maid.fromJson(Map<String, dynamic> json) {
    return Maid(id: json['id'], name: json['name'], address: json['address']);
  }
}
