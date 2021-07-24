part of 'loading_cubit.dart';

abstract class LoadingState extends Equatable {
  const LoadingState();

  @override
  List<Object> get props => [];
}

class LoadingInitial extends LoadingState {}

class LoadingSuccess extends LoadingState {}

class LoadingFailed extends LoadingState {}
