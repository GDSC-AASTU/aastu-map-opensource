import 'package:aastu_map/pages/about/aastu_info_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String aastuInfo = '/aastu-info';

  static final Map<String, Widget Function(BuildContext)> routes = {
    aastuInfo: (context) => const AASTUInfoPage(),
  };
} 