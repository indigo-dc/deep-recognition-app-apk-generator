
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
  final String metadata;
  final Links links;

  Info({this.metadata, this.links});

  factory Info.fromJson(Map<String, dynamic> json) {
    //var list = json["links"] as List;
    //List<Links> links = list.map((i) =>
    //Links.fromJson(i)).toList();
    return Info(
        metadata: json["metadata"],
        links: Links.fromJson(json["links"]),
    );
  }

  Map<String, dynamic> toJson() =>
      {
        "metadata": metadata, "links": links.toJson()
      };

}

class Links{
  final String wikipedia;
  final String google_images;

  Links({this.wikipedia, this.google_images});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      wikipedia: json["Wikipedia"],
      google_images: json["Google images"]
    );
  }

  Map<String, dynamic> toJson() =>
      {
         "Wikipedia": wikipedia, "Google images": google_images,
      };

}