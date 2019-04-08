
class Task{
  final int id;
  final List<String> images_paths;
  final Results results;

  Task(this.id, this.images_paths, this.results);

  Map toJson() => {"id": id, "images_paths": images_paths, "results" : results};
}

class Results{
  final String status;
  final List<Prediction> predictions;

  Results({this.status, this.predictions});

  factory Results.fromJson(Map<String, dynamic> json) {
    var list = json["predictions"] as List;
    List<Prediction> predictions = list.map((i) =>
    Prediction.fromJson(i)).toList();
    return Results(
      status: json["status"],
      predictions: predictions
    );
  }

  Map toJson() => {"status": status, "predictions": predictions};
}

class Prediction{
  final Info info;
  final int label_id;
  final double probability;
  final String label;

  Prediction({this.info, this.label_id, this.probability, this.label});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      info: Info.fromJson(json["info"]),
      label_id: json["label_id"],
      probability: json["probability"],
      label: json["label"]
    );
  }

  Map toJson() => {"info": info, "label_id": label_id, "probability" : probability, "label" : label};
}

class Info{
  final List<Link> links;
  final String metadata;

  Info({this.links, this.metadata});

  factory Info.fromJson(Map<String, dynamic> json) {
    var list = json["links"] as List;
    List<Link> links = list.map((i) =>
    Link.fromJson(i)).toList();
    return Info(
      links: links,
      metadata: json["metadata"]
    );
  }
}

class Link{
  final String url;
  final String link;

  Link({this.url, this.link});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json["url"],
      link: json["link"]
    );
  }
}