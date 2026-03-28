/// Path segment types for form field access.
sealed class PathSegment {
  const PathSegment();
}

/// A key-based segment for accessing map entries (e.g., "address" in "address.street").
class KeySegment extends PathSegment {
  final String key;
  const KeySegment(this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is KeySegment && key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => key;
}

/// An index-based segment for accessing array elements (e.g., "[0]" in "items.[0]").
class IndexSegment extends PathSegment {
  final int index;
  const IndexSegment(this.index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IndexSegment && index == other.index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => '[$index]';
}

/// Parses and represents a form field path.
///
/// Supports the following path formats:
/// - "email" -> [KeySegment("email")]
/// - "address.street" -> [KeySegment("address"), KeySegment("street")]
/// - "items.[0]" -> [KeySegment("items"), IndexSegment(0)]
/// - "items.[0].name" -> [KeySegment("items"), IndexSegment(0), KeySegment("name")]
class FormPath {
  final List<PathSegment> segments;

  const FormPath(this.segments);

  /// Parses a path string into a FormPath.
  factory FormPath.parse(String path) {
    if (path.isEmpty) {
      return const FormPath([]);
    }

    final segments = <PathSegment>[];
    final parts = path.split('.');

    for (final part in parts) {
      if (part.isEmpty) continue;

      // Check if it's an index segment: [0], [1], etc.
      if (part.startsWith('[') && part.endsWith(']')) {
        final indexStr = part.substring(1, part.length - 1);
        final index = int.tryParse(indexStr);
        if (index != null) {
          segments.add(IndexSegment(index));
        } else {
          // Treat as key if not a valid integer
          segments.add(KeySegment(part));
        }
      } else {
        segments.add(KeySegment(part));
      }
    }

    return FormPath(segments);
  }

  /// Returns true if the path is empty.
  bool get isEmpty => segments.isEmpty;

  /// Returns true if the path is not empty.
  bool get isNotEmpty => segments.isNotEmpty;

  /// Returns the number of segments in the path.
  int get length => segments.length;

  /// Returns the first segment, or null if empty.
  PathSegment? get first => segments.isEmpty ? null : segments.first;

  /// Returns a new path without the first segment.
  FormPath get rest => FormPath(segments.skip(1).toList());

  /// Returns the string representation of this path.
  String toPathString() {
    if (segments.isEmpty) return '';

    final buffer = StringBuffer();
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (i > 0 && segment is KeySegment) {
        buffer.write('.');
      } else if (segment is IndexSegment && i > 0) {
        buffer.write('.');
      }
      buffer.write(segment.toString());
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FormPath) return false;
    if (segments.length != other.segments.length) return false;
    for (var i = 0; i < segments.length; i++) {
      if (segments[i] != other.segments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(segments);

  @override
  String toString() => 'FormPath(${toPathString()})';
}
