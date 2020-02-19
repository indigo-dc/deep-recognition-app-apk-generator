class Post{
  final List<Parameter> parameters;
  final List<String> produces;

  Post({this.parameters, this.produces});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      parameters: json["parameters"] == null ? null : (json["parameters"] as List).map((i) => Parameter.fromJson(i)).toList(),
      produces: json['produces'] == null ? null : new List<String>.from(json["produces"])
    );
  }
}


class Parameter{
  final String in_;
  final String name;
  final bool required;
  final String default_;
  final bool x_nullable;
  final String description;
  final List<String> enum_;
  final String type;

  Parameter({this.in_, this.name, this.required, this.default_, this.x_nullable, this.description, this.enum_, this.type});

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      in_: json["in"] == null ? null : json["in"],
      name: json["name"] == null ? null : json["name"],
      required: json["required"] == null ? null : json["required"],
      default_: json["default"] == null ? null : json["default"],
      x_nullable: json["x-nullable"] == null ? null : json["x-nullable"],
      enum_: json['enum'] == null ? null : new List<String>.from(json["enum"]),
      description: json["type"] == null ? null : json["type"]
    );
  }

}