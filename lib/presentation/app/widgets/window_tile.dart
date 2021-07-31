import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/window/cubit/window_cubit.dart';
import 'package:nyrna/domain/native_platform/native_platform.dart';

/// Represents a visible window on the desktop, running state and actions.
class WindowTile extends StatelessWidget {
  const WindowTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<WindowCubit, WindowState>(
      listener: (context, state) {
        if (state.toggleError == ToggleError.Suspend) {
          _showSnackError(context, ToggleError.Suspend);
        } else if (state.toggleError == ToggleError.Resume) {
          _showSnackError(context, ToggleError.Resume);
        }
      },
      child: Card(
        child: ListTile(
          leading: _StatusWidget(),
          title: _TitleWidget(),
          subtitle: _DetailsWidget(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 20,
          ),
          onTap: () => context.read<WindowCubit>().toggle(),
        ),
      ),
    );
  }

  Future<void> _showSnackError(
    BuildContext context,
    ToggleError errorType,
  ) async {
    final state = context.read<WindowCubit>().state;
    final name = state.executable;
    final suspendMessage = 'There was a problem suspending $name';
    final resumeMessage = 'There was a problem resuming $name';
    final message =
        (errorType == ToggleError.Suspend) ? suspendMessage : resumeMessage;
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _StatusWidget extends StatelessWidget {
  const _StatusWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WindowCubit, WindowState>(
      builder: (context, state) {
        Color _color;
        switch (state.processStatus) {
          case ProcessStatus.normal:
            _color = Colors.green;
            break;
          case ProcessStatus.suspended:
            _color = Colors.orange[700]!;
            break;
          case ProcessStatus.unknown:
            _color = Colors.grey;
        }

        return Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _color,
          ),
        );
      },
    );
  }
}

class _TitleWidget extends StatelessWidget {
  const _TitleWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WindowCubit, WindowState>(
      builder: (context, state) {
        return Text(state.title);
      },
    );
  }
}

class _DetailsWidget extends StatelessWidget {
  const _DetailsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<WindowCubit, WindowState>(
          builder: (context, state) {
            return Text('PID: ${state.pid}');
          },
        ),
        BlocBuilder<WindowCubit, WindowState>(
          builder: (context, state) {
            return Text(state.executable);
          },
        ),
      ],
    );
  }
}
