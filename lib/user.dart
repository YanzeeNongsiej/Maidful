class Users {
  final String userid;
  final String username;
  final String role;
  final String name;
  final String gender;
  final String address;
  final String dob;
  final String language;
  final String remarks;

  Users(
      {required this.userid,
      required this.username,
      required this.role,
      required this.name,
      required this.gender,
      required this.address,
      required this.dob,
      required this.language,
      required this.remarks});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
        userid: json['userid'],
        username: json['username'],
        role: json['role'],
        name: json['name'],
        gender: json['gender'],
        address: json['address'],
        dob: json['dob'],
        language: json['language'],
        remarks: json['remarks']);
  }

  toJson() {
    return {
      "username": username,
      "role": role,
      "name": name,
      "gender": gender,
      "address": address,
      "dob": dob,
      "language": language,
      "remarks": remarks,
    };
  }
}
