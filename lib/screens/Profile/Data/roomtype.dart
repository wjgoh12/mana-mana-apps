class RoomType {
  final String name;
  final String image;
  final int points;
  int quantity;

  RoomType({
    required this.name,
    required this.image,
    required this.points,
    this.quantity = 1,
  });

  // Create RoomType from API JSON
  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      points: json['points'] ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }
}

final List<RoomType> roomTypes = [
  RoomType(
    name: 'Garnet Room',
    image: 'assets/images/garnet.png',
    points: 14000,
  ),
  RoomType(
    name: 'Emerald Suite',
    image: 'assets/images/emerald.png',
    points: 20000,
  ),
  RoomType(
    name: 'Sapphire Deluxe',
    image: 'assets/images/sapphire.png',
    points: 17000,
  ),
  RoomType(
    name: 'Ruby Premium',
    image: 'assets/images/ruby.png',
    points: 18000,
  ),
];
