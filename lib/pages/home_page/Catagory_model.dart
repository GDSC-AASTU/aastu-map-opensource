import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class CatagoryModel {
  final String name;
  final IconData icon;
  final bool selected;

  CatagoryModel({
    required this.name,
    required this.icon,
    this.selected = false,
  });
}

List<CatagoryModel> catagory = [
  CatagoryModel(
      name: "Lounge", icon: LineIcons.coffee, selected: false),
  CatagoryModel(
      name: "Library", icon: LineIcons.book, selected: false),
  CatagoryModel(
      name: "Registrar", icon: LineIcons.clipboardList, selected: false),
  CatagoryModel(
      name: "Cafeteria", icon: LineIcons.utensils, selected: false),
  CatagoryModel(
      name: "Labs", icon: LineIcons.laptop, selected: false),
  CatagoryModel(
      name: "Classrooms", icon: LineIcons.chalkboardTeacher, selected: false),
  CatagoryModel(
      name: "Sports", icon: LineIcons.basketballBall, selected: false),
  CatagoryModel(
      name: "Parking", icon: LineIcons.parking, selected: false),
  CatagoryModel(
      name: "Dormitory", icon: LineIcons.bed, selected: false),
  CatagoryModel(
      name: "Clinic", icon: LineIcons.firstAid, selected: false),
  CatagoryModel(
      name: "Offices", icon: LineIcons.building, selected: false),
  CatagoryModel(
      name: "ATM", icon: LineIcons.creditCard, selected: false),
];
