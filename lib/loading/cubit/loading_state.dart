part of 'loading_cubit.dart';

abstract class LoadingState extends Equatable {
  const LoadingState();

  @override
  List<Object> get props => [];
}

class LoadingInitial extends LoadingState {
  const LoadingInitial();
}

class LoadingSuccess extends LoadingState {
  const LoadingSuccess();
}

class LoadingError extends LoadingState {
  final String errorMsg;

  const LoadingError({
    required this.errorMsg,
  });

  @override
  List<Object> get props => [errorMsg];
}

class LoadingDependencyError extends LoadingError {
  const LoadingDependencyError()
      : super(
          errorMsg: '''
Dependency check failed.

Install the dependencies from your system's package manager:

- `xdotool`
- `wmctrl`''',
        );
}

class LoadingWaylandError extends LoadingError {
  const LoadingWaylandError()
      : super(
          errorMsg: '''
Wayland is not currently supported.

[Sign in using X11 instead](https://docs.fedoraproject.org/en-US/quick-docs/configuring-xorg-as-default-gnome-session/).''',
        );
}
