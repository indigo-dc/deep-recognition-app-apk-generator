import 'package:flutter/material.dart';

class AppStrings {
  static String app_label = "Marine Conus API";
  static String analysis = "Analysis";
  static String history = "History";
  static String credits = "Credits";
  static String preview_default_img_path = "assets/images/plant.png";
  static String camera = "CAMERA";
  static String file = "FILE";
  static String select_photo_info = "Select at least one photo";
  static String api_url = "http://ribes-230.man.poznan.pl:443/";
  static String post_endpoint = "models/plant_classification/predict";
  static String delete_alert_content = "The image will be deleted. Are you sure?";
}

class AppColors {
  static const Color primary_color = Color(0xFF35B4C5);
  static const Color accent_color = Color(0xFF3990DC);
  static const Color notification_color = Color(0xD3212121);
  static const Color primary_dark_color = Color(0xFF007393);
}

class AppDimensions {
  static const double task_result_row_size = 18.0;
}