class Task{
  final int id;
  final List<String> file_paths;
  final PredictResponse predictResponse;
  final String media_input_type;

  Task({this.id, this.file_paths, this.predictResponse, this.media_input_type});

  factory Task.fromJson(Map<String, dynamic> json) {
    var list = json['image_paths'];
    List<String> image_paths = new List<String>.from(list);
    return Task(
      id: json["id"],
      file_paths: image_paths,
      predictResponse: PredictResponse.fromJson(json["predict_response"]),
      media_input_type: json["media_input_type"],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "image_paths": file_paths,
        "predict_response": predictResponse.toJson(),
        "media_input_type": media_input_type
      };
}

class PredictResponse {
  String status;
  Predictions predictions;

  PredictResponse({this.status, this.predictions});

  PredictResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    predictions = json['predictions'] != null
        ? new Predictions.fromJson(json['predictions'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.predictions != null) {
      data['predictions'] = this.predictions.toJson();
    }
    return data;
  }
}

class Predictions {
  List<String> labels;
  List<double> probabilities;
  List<String> labelsInfo;
  Links links;

  Predictions({this.labels, this.probabilities, this.labelsInfo, this.links});

  Predictions.fromJson(Map<String, dynamic> json) {
    labels = json['labels'].cast<String>();
    probabilities = json['probabilities'].cast<double>();
    labelsInfo = json['labels_info'].cast<String>();
    links = json['links'] != null ? new Links.fromJson(json['links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['labels'] = this.labels;
    data['probabilities'] = this.probabilities;
    data['labels_info'] = this.labelsInfo;
    if (this.links != null) {
      data['links'] = this.links.toJson();
    }
    return data;
  }
}

class Links {
  List<String> googleImages;
  List<String> wikipedia;

  Links({this.googleImages, this.wikipedia});

  Links.fromJson(Map<String, dynamic> json) {
    googleImages = json['Google Images'].cast<String>();
    wikipedia = json['Wikipedia'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Google Images'] = this.googleImages;
    data['Wikipedia'] = this.wikipedia;
    return data;
  }
}

/*class Results{
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

}*/