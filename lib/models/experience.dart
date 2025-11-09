/// A data model representing a user-selectable experience, hobby, or interest.
///
/// Used in onboarding flows, profile setup, and recommendation systems
/// to allow users to pick activities they enjoy (e.g., "Hiking", "Photography", "Foodie").
///
/// Each experience is backed by:
/// - A unique identifier (`id`)
/// - A display name (`name`)
/// - A remote image URL (`imageUrl`) for visual representation
///
/// This model is typically populated from a JSON API response.
class Experience {
  /// Unique identifier for the experience.
  /// Used for database referencing, selection tracking, and API requests.
  final int id;

  /// Human-readable name displayed to the user.
  /// Example: "Street Photography", "Camping", "Live Music"
  final String name;

  /// Full URL to the experience's icon/image hosted on a CDN.
  /// Should point to a square, high-quality image (e.g., 512x512).
  /// Used in [ExperienceCard] and other UI components.
  final String imageUrl;

  /// Constructs an [Experience] instance.
  ///
  /// All fields are required to ensure data integrity.
  Experience({required this.id, required this.name, required this.imageUrl});

  /// Creates an [Experience] instance from a JSON map.
  ///
  /// Expected JSON format:
  /// ```json
  /// {
  ///   "id": 42,
  ///   "name": "Surfing",
  ///   "image_url": "https://cdn.example.com/experiences/surfing.jpg"
  /// }
  /// ```
  ///
  /// This factory enables easy deserialization when fetching from a backend.
  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}