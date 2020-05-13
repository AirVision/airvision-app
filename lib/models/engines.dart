class Engines{
  Engines(this.type, this.count, this.name);

  String type;
  int count;
  String name;

  
   factory Engines.fromJson(dynamic json) {
    return Engines(
      json['type'] as String,
      json['count'] as int,
      json['name'] as String,
    );
  }
}