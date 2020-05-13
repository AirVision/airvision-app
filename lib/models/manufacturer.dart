class Manufacturer{
  Manufacturer({this.name, this.country});

  String name;
  String country;

   factory Manufacturer.fromJson(dynamic json) {
    return Manufacturer(
      name: json['name'] as String,
      country: json['country'] as String,
    );
  }
}