
class Task{
  final int id;
  final List<String> image_paths;
  final Results results;

  Task({this.id, this.image_paths, this.results});


  factory Task.fromJson(Map<String, dynamic> json) {
    var list = json['image_paths'];
    List<String> image_paths = new List<String>.from(list);
    return Task(
      id: json["id"],
      image_paths: image_paths,
      results: Results.fromJson(json["results"])
    );
  }

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "image_paths": image_paths,
        "results": results.toJson()
      };
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

  Map<String, dynamic> toJson() =>
      {
        "status": status, "predictions": predictions.map((p) => p.toJson()).toList()
      };
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

  Map toJson() => {"info": info.toJson(), "label_id": label_id, "probability" : probability, "label" : label};
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

  Map<String, dynamic> toJson() =>
      {
        "links": links.map((l) => l.toJson()).toList(), "metadata": metadata
      };

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

  Map<String, dynamic> toJson() =>
      {
        "url": url, "link": link
      };

}