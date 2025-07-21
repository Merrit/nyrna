import '../../native_platform/native_platform.dart';
import '../enums.dart';

/// Contains information about an error interacting with a window / process.
class InteractionError {
  final InteractionType interactionType;
  final ProcessStatus statusAfterInteraction;
  final String windowId;

  const InteractionError({
    required this.interactionType,
    required this.statusAfterInteraction,
    required this.windowId,
  });
}
