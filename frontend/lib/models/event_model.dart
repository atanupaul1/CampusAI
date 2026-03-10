/// Campus AI Assistant — Event Data Model
///
/// Represents a campus event as returned by the /events endpoint.
/// Used in the events screen and event cards.

class EventModel {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? category;
  final String? sourceUrl;
  final DateTime? createdAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.startTime,
    this.endTime,
    this.category,
    this.sourceUrl,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      category: json['category'] as String?,
      sourceUrl: json['source_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
