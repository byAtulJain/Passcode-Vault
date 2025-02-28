class Credential {
  final String heading;
  final String email;
  final String password;
  final int color;
  final String? pin; // New field for storing PIN

  Credential({
    required this.heading,
    required this.email,
    required this.password,
    required this.color,
    this.pin, // Optional PIN
  });

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'email': email,
        'password': password,
        'color': color,
        'pin': pin, // Store PIN
      };

  factory Credential.fromJson(Map<String, dynamic> json) => Credential(
        heading: json['heading'],
        email: json['email'],
        password: json['password'],
        color: json['color'],
        pin: json['pin'], // Retrieve PIN
      );
}
