import 'package:flutter/material.dart';

class AppStrings {
  static String app_label = "TEST LABEL";
  static String analysis = "Analysis";
  static String history = "History";
  static String credits = "Credits";
  static String preview_default_img_path = "assets/images/plant.png";
  static String camera = "CAMERA";
  static String file = "FILE";
  static String select_photo_info = "Select at least one photo";
  static String api_url = "http://127.0.0.1:5000/";
  static String post_endpoint = "v2/models/audioclas/predict";
  //static String api_url_def = "http://ribes-230.man.poznan.pl:443/";
  //static String post_endpoint_def = "models/plant_classification/predict";
  static String delete_alert_content = "The image will be deleted. Are you sure?";
  static String no = "NO";
  static String yes = "YES";
  static String no_history = "No history";
  static String default_preview_message = "Take a photo or choose from gallery";
  static String task_processing_message = "Please wait...";
  static String network_exception_message = "Network connection problem";
  static String network_error = "Error code";
  static String launch_exception = "Could not launch";
}

class AppColors {
  static const Color primary_color = Color(0xFF8cadac);
  static const Color accent_color = Color(0xFF441975);
  static const Color notification_color = Color(0xD3212121);
  static const Color primary_dark_color = Color(0xFF255059);
}
