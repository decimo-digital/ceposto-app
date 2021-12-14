class Restaurant {
  final int id;
  final num distance;
  final int freeSeats;
  final int totalSeats;
  final num occupancyRate;
  final String name;
  final int owner;

  Restaurant({
    this.id,
    this.distance,
    this.freeSeats,
    this.totalSeats,
    this.occupancyRate,
    this.name,
    this.owner,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    try {
      return Restaurant(
        id: json['id'],
        distance: json['distance'],
        freeSeats: json['freeSeats'],
        totalSeats: json['totalSeats'],
        occupancyRate: json['occupancyRate'],
        name: json['storeName'],
        owner: json['owner'],
      );
    } catch (e) {
      print('[Restaurant-fromJson] Failed to parse restaurant: $e');
      rethrow;
    }
  }
}
