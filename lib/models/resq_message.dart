import 'dart:convert';

/// ResQMessage - Core data structure for emergency messages
/// Transmitted between devices in the P2P mesh network
class ResQMessage {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final int timestamp;
  final String message; // Custom emergency message from victim
  final int hopCount; // Track how many hops this message has taken

  ResQMessage({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.timestamp,
    this.message = 'SOS - Emergency!', // Default message
    this.hopCount = 0,
  });

  /// Convert ResQMessage to JSON for transmission
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lon': lon,
      'timestamp': timestamp,
      'message': message,
      'hopCount': hopCount,
    };
  }

  /// Create ResQMessage from JSON
  factory ResQMessage.fromJson(Map<String, dynamic> json) {
    return ResQMessage(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
      message: json['message'] as String? ?? 'SOS - Emergency!',
      hopCount: json['hopCount'] as int? ?? 0,
    );
  }

  /// Convert to JSON string for transmission over network
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create ResQMessage from JSON string
  factory ResQMessage.fromJsonString(String jsonString) {
    return ResQMessage.fromJson(jsonDecode(jsonString));
  }

  /// Get formatted timestamp
  String getFormattedTime() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Get formatted date
  String getFormattedDate() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Get coordinates as string
  String getCoordinatesString() {
    return 'Lat: ${lat.toStringAsFixed(6)}, Lon: ${lon.toStringAsFixed(6)}';
  }

  @override
  String toString() {
    return 'ResQMessage{id: $id, name: $name, message: $message, lat: $lat, lon: $lon, timestamp: $timestamp, hops: $hopCount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResQMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Create a copy with incremented hop count for relay
  ResQMessage incrementHop() {
    return ResQMessage(
      id: id,
      name: name,
      lat: lat,
      lon: lon,
      timestamp: timestamp,
      message: message,
      hopCount: hopCount + 1,
    );
  }
}
