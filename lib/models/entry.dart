/// Model wpisu w dzienniku lokalizacji
class Entry {
  final int? id;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime createdAt;

  Entry({
    this.id,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Tworzy Entry z JSON (z API)
  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['body'] as String? ?? json['description'] as String? ?? '',
      latitude: json['latitude'] != null 
          ? (json['latitude'] as num).toDouble() 
          : null,
      longitude: json['longitude'] != null 
          ? (json['longitude'] as num).toDouble() 
          : null,
      address: json['address'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Konwertuje Entry do JSON (dla API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': description,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Sprawdza czy wpis ma lokalizację
  bool get hasLocation => latitude != null && longitude != null;

  /// Tworzy kopię z nowymi wartościami
  Entry copyWith({
    int? id,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? createdAt,
  }) {
    return Entry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Entry(id: $id, title: $title, lat: $latitude, lng: $longitude)';
  }
}

