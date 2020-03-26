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
    if(json['predictions'] is List<dynamic>) {
      predictions = Predictions.fromJson(json['predictions'][0]);
    } else {
      predictions = json['predictions'] != null
          ? Predictions.fromJson(json['predictions'])
          : null;
    }
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

  Predictions({this.labels, this.probabilities, this.labelsInfo, this.links/*, this.title*/});

  Predictions.fromJson(Map<String, dynamic> json) {
    labels = json['labels'].cast<String>();
    probabilities = json['probabilities'].cast<double>();
    labelsInfo = json['labels_info'] != null ? json['labels_info'].cast<String>() : null;
    links = json['links'] != null ? new Links.fromJson(json['links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['labels'] = this.labels;
    data['probabilities'] = this.probabilities;
    if(this.labelsInfo != null) {
      data['labels_info'] = this.labelsInfo;
    }
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