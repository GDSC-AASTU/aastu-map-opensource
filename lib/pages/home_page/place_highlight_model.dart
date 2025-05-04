class Places {
  final String name;
  final List<String> images;
  final String description;
  final List<String> place_features;
  final String location_description;
  final String building;

  Places(
      {required this.name,
      required this.images,
      required this.description,
      required this.place_features,
      required this.location_description,
      required this.building});
}

List<Places> placelist = [
  Places(
      name: "Engineering Library",
      images: [
        "assets/library.jpg",
      ],
      description:
          "AASTU Engineering library has a capacity to serve more than 2000 students and works 24/7. ",
      place_features: [],
      location_description: "Next to Kibnesh",
      building: "Block 53"),
  Places(
      name: "Student Center",
      images: ["assets/student_center.jpg"],
      description:
          "The main hub for student activities, events, and social gatherings on campus.",
      place_features: [],
      location_description: "Central Campus",
      building: "Block 42"),
  Places(
      name: "Cafeteria",
      images: ["assets/cafeteria.jpg"],
      description:
          "Serves a variety of meals and snacks for students and staff throughout the day.",
      place_features: [],
      location_description: "Near Engineering Library",
      building: "Block 51"),
  Places(
      name: "Sports Complex",
      images: ["assets/sports.jpg"],
      description:
          "Features basketball courts, football field, and other sports facilities for students.",
      place_features: [],
      location_description: "East Campus",
      building: "Block 78"),
  Places(
      name: "Computer Lab",
      images: ["assets/computer_lab.jpg"],
      description:
          "Modern computer lab with high-speed internet and specialized software for engineering students.",
      place_features: [],
      location_description: "Next to Engineering Building",
      building: "Block 45")
];
