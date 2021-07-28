import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyrna/application/theme/theme.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ThemeChooser(),
        // const _IconCustomizer(),
      ],
    );
  }
}

class _ThemeChooser extends StatelessWidget {
  const _ThemeChooser({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Theme'),
            RadioListTile<AppTheme>(
              title: const Text('Dark'),
              groupValue: state.appTheme,
              value: AppTheme.dark,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
            RadioListTile<AppTheme>(
              title: const Text('Pitch Black'),
              groupValue: state.appTheme,
              value: AppTheme.pitchBlack,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
            RadioListTile<AppTheme>(
              title: const Text('Light'),
              groupValue: state.appTheme,
              value: AppTheme.light,
              onChanged: (value) => themeCubit.changeTheme(value!),
            ),
          ],
        );
      },
    );
  }
}

// class _IconCustomizer extends StatelessWidget {
//   const _IconCustomizer({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(Icons.color_lens),
//       title: Text('Icon color'),
//       trailing: ColorIndicator(),
//       onTap: () => _pickIconColor(),
//     );
//   }

//   Future<void> _pickIconColor() async {
//     var iconColor = Color(settings.iconColor);
//     final iconManager = IconManager();
//     final iconUint8List = await iconManager.iconUint8List;
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: StatefulBuilder(
//             builder: (context, setState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ColorPicker(
//                     // Current color is pre-selected.
//                     color: iconColor,
//                     onColorChanged: (Color color) {
//                       setState(() => iconColor = color);
//                     },
//                     heading: Text('Select color'),
//                     subheading: Text('Select color shade'),
//                     pickersEnabled: const <ColorPickerType, bool>{
//                       ColorPickerType.primary: true,
//                       ColorPickerType.accent: false,
//                     },
//                   ),
//                   Image.memory(
//                     iconUint8List,
//                     height: 150,
//                     width: 150,
//                     color: iconColor,
//                   ),
//                 ],
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//     if (confirmed == null) return;
//     // await _updateIcon();
//     // await settings.setIconColor(newColor!.value);
//   }
// }
