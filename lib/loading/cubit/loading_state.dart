part of 'loading_cubit.dart';

@freezed
abstract class LoadingState with _$LoadingState {
  const factory LoadingState.initial() = LoadingInitial;
  const factory LoadingState.success() = LoadingSuccess;
  const factory LoadingState.error({required String errorMsg}) = LoadingError;
}
