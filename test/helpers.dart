import 'package:mockito/mockito.dart';

/// Extension to allow `thenAnswerInOrder` (different values for multiple async calls).
///
/// From: https://github.com/dart-lang/mockito/issues/221#issuecomment-2034267995
/// Open issue: https://github.com/dart-lang/mockito/issues/704
extension When<T> on PostExpectation<T> {
  void thenAnswerInOrder(List<T> values) {
    int callCount = 0;
    thenAnswer((_) => values[callCount++]);
  }
}
