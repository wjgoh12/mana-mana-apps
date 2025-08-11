class RoomType {
  final String name;
  final String image;
  final int points;
  final int quantity; // mutable so it can change when user selects

  RoomType({
    required this.name,
    required this.image,
    required this.points,
    this.quantity = 1, // default to 1 room
  });
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
