/// Poster Request data models
library;

/// Placeholder data model for poster requests
/// TODO: Replace with actual business logic implementation when BLE service is implemented
///
/// This model represents a poster pull request sent from Front Desk to Back Office

class PosterRequest {
  final String id; // Unique identifier
  final String posterNumber; // Alphanumeric poster number (e.g., "A457", "B211")
  final DateTime timestampSent; // When the request was sent
  final DateTime? timestampFulfilled; // When the request was fulfilled (null if pending)
  final RequestStatus status; // Current status of the request

  const PosterRequest({
    required this.id,
    required this.posterNumber,
    required this.timestampSent,
    this.timestampFulfilled,
    required this.status,
  });

  /// Create a copy with updated fields
  PosterRequest copyWith({
    String? id,
    String? posterNumber,
    DateTime? timestampSent,
    DateTime? timestampFulfilled,
    RequestStatus? status,
  }) {
    return PosterRequest(
      id: id ?? this.id,
      posterNumber: posterNumber ?? this.posterNumber,
      timestampSent: timestampSent ?? this.timestampSent,
      timestampFulfilled: timestampFulfilled ?? this.timestampFulfilled,
      status: status ?? this.status,
    );
  }

  /// Check if request is fulfilled
  bool get isFulfilled => status == RequestStatus.fulfilled;

  /// Check if request is pending
  bool get isPending => status == RequestStatus.pending;

  /// Check if request is sent but not acknowledged
  bool get isSent => status == RequestStatus.sent;
}

/// Status of a poster request
enum RequestStatus {
  sent, // Request sent from Front Desk, awaiting acknowledgment
  pending, // Acknowledged by Back Office, being fulfilled
  fulfilled, // Completed successfully
}

extension RequestStatusExtension on RequestStatus {
  /// Display label for status
  String get label {
    switch (this) {
      case RequestStatus.sent:
        return 'SENT';
      case RequestStatus.pending:
        return 'PENDING';
      case RequestStatus.fulfilled:
        return 'FULFILLED';
    }
  }

  /// Icon for status
  String get icon {
    switch (this) {
      case RequestStatus.sent:
        return '→'; // Arrow for sent
      case RequestStatus.pending:
        return '⏳'; // Hourglass for pending
      case RequestStatus.fulfilled:
        return '✓'; // Checkmark for fulfilled
    }
  }
}
