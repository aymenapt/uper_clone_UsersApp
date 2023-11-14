class PlacesPredictions {
  String? place_id;
  String? main_text;
  String? secondary_text;
  String? description;

  PlacesPredictions(
      {required this.place_id,
      required this.main_text,
      required this.secondary_text,
      required this.description});

  factory PlacesPredictions.fromMap(Map<String, dynamic> json) =>
      PlacesPredictions(
          place_id: json["place_id"] ?? "",
          main_text: json["structured_formatting"]["main_text"] ?? "",
          secondary_text: json["structured_formatting"]["secondary_text"] ?? "",
          description: json["description"] ?? "");
}
