import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

/// Validates uploaded files for security.
class FileValidator {
  /// Dangerous file extensions that are always blocked.
  static const blockedExtensions = <String>{
    '.exe', '.dll', '.so', '.dylib',
    '.bat', '.cmd', '.sh', '.bash', '.zsh', '.ps1',
    '.php', '.php3', '.php4', '.php5', '.phtml',
    '.jsp', '.jspx', '.asp', '.aspx',
    '.py', '.pyc', '.pyo', '.pl', '.rb',
    '.js', '.mjs', '.cjs', '.vbs', '.vbe',
    '.jar', '.war', '.class',
    '.com', '.scr', '.pif', '.msi', '.hta',
  };

  /// Validates file extension is not dangerous.
  static bool isExtensionAllowed(String filename) {
    final ext = p.extension(filename).toLowerCase();
    return !blockedExtensions.contains(ext);
  }

  /// Detects MIME type from filename and file content (magic bytes).
  ///
  /// Uses the `mime` package which checks both extension and header bytes.
  /// Returns detected MIME type or 'application/octet-stream' if unknown.
  static String detectMimeType(String filename, Uint8List? headerBytes) {
    return lookupMimeType(
          filename,
          headerBytes: headerBytes,
        ) ??
        'application/octet-stream';
  }

  /// Validates that claimed MIME type is compatible with detected type.
  ///
  /// Returns true if types are compatible (same category or exact match).
  static bool isMimeTypeValid(String claimed, String detected) {
    // Unknown detected type - can't verify, allow it
    if (detected == 'application/octet-stream') {
      return true;
    }

    // Generic claimed type - not making a specific claim, allow it
    if (claimed == 'application/octet-stream') {
      return true;
    }

    // Exact match
    if (claimed == detected) {
      return true;
    }

    // Same category (image/*, audio/*, video/*, etc.)
    final claimedCategory = claimed.split('/').first;
    final detectedCategory = detected.split('/').first;
    if (claimedCategory == detectedCategory) {
      return true;
    }

    // ZIP-based formats (docx, xlsx, etc. are ZIP containers)
    if (detected == 'application/zip') {
      if (claimed.contains('officedocument') ||
          claimed.contains('epub') ||
          claimed == 'application/java-archive') {
        return true;
      }
    }

    return false;
  }

  /// Performs full validation of an uploaded file.
  ///
  /// Returns null if valid, or an error message if invalid.
  static String? validate({
    required String filename,
    required String claimedMimeType,
    Uint8List? headerBytes,
  }) {
    // Check blocked extensions
    if (!isExtensionAllowed(filename)) {
      return 'File type not allowed: ${p.extension(filename)}';
    }

    // Detect actual MIME type from content
    if (headerBytes != null && headerBytes.isNotEmpty) {
      final detected = detectMimeType(filename, headerBytes);

      if (!isMimeTypeValid(claimedMimeType, detected)) {
        return 'File content does not match declared type. '
            'Claimed: $claimedMimeType, Detected: $detected';
      }
    }

    return null;
  }
}
