import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/app/app.dart';
import 'package:nyrna/application/preferences/cubit/preferences_cubit.dart';

import '../../styles.dart';

/// Add shortcuts and icons for portable builds.
class IntegrationSection extends StatelessWidget {
  const IntegrationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (!Platform.isLinux) // TODO: Add integration function for Windows.
        ? const SizedBox()
        : BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              return state.isPortable
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacers.verticalMedium,
                        const Text('System Integration'),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.add_circle_outline),
                          title: const Text('Add Nyrna to launcher'),
                          onTap: () => _confirmAddToLauncher(context),
                        ),
                      ],
                    )
                  : const SizedBox();
            },
          );
  }

  /// Confirm with the user before adding .desktop and icon files.
  void _confirmAddToLauncher(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 150.0,
            vertical: 24.0,
          ),
          content: const Text('This will add a menu item to the system '
              'launcher with an associated icon so launching Nyrna is easier.'
              '\n\n'
              'Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await preferencesCubit.createLauncher();
                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}
