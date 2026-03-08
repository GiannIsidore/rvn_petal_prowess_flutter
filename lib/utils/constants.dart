import 'package:flutter/material.dart';

class AppConstants {
  static const Color primaryColor = Color(0xFF2F6B3F);
  static const Color primaryDark = Color(0xFF245432);
  static const Color backgroundColor = Color(0xFFF5F7F6);
  static const Color lightGreen = Color(0xFFE8F5E9);

  static const String shopEmail = 'rvnpetalprowess@gmail.com';
  static const String shopPhone = '0935-742-4593';
  static const String shopAddress =
      'Zone 1, Sankanan, Manolo Fortich, Bukidnon';
  static const String shopHours = '8AM - 6PM -- MON - SAT';

  static const double shopLatitude = 8.308476;
  static const double shopLongitude = 124.858435;
  static const double deliveryRatePerKm = 10.0;

  static const Map<String, Map<String, double>> productPrices = {
    'Assorted Flowers': {'Small': 150.0, 'Medium': 250.0, 'Large': 350.0},
    'Custom Bouquet': {'Small': 500.0, 'Medium': 1000.0, 'Large': 1500.0},
    'Custom Pot': {'Small': 150.0, 'Medium': 250.0, 'Large': 350.0},
  };

  static const List<String> flowerPreferences = [
    'Roses',
    'Sunflowers',
    "Baby's Breath",
    'Lisianthus',
    'Zinnia',
  ];

  static const List<String> sizes = ['Small', 'Medium', 'Large'];

  static const List<String> orderStatuses = [
    'Pending',
    'Processing',
    'Ready',
    'Rejected',
    'Completed',
  ];
}
