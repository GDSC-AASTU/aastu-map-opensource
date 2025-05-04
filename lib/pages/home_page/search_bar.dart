import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/discover/discover_page.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class SearchBAR extends StatelessWidget {
  final TextEditingController controller;

  const SearchBAR({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: GestureDetector(
        onTap: () {
          // Navigate to discover page using Navigator
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DiscoverPage(),
            ),
          );
        },
        child: AbsorbPointer(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCDCDCD).withOpacity(.2),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                  offset: const Offset(0.0, 3.0),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  LineIcons.search,
                  color: AppColors.primary,
                ),
                suffixIcon: const Icon(
                  LineIcons.locationArrow,
                  color: AppColors.primary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 15.0),
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
