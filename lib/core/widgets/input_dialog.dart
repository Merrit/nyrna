import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/app_localizations.dart';

/// Allows to easily specify dialog properties such as the text field only
/// accepting input as a double, which type of soft keyboard to show, etc.
enum InputDialogs {
  multiLine,
  onlyDouble,
  onlyInt,
}

/// Convenience function to show a dialog with a TextFormField so that the user
/// can enter some data. Return is the String entered, or an empty string if the
/// field was left blank.
Future<String?> showInputDialog({
  required BuildContext context,
  InputDialogs? type,
  String? title,
  String? hintText,
  String? initialValue,
}) async {
  TextInputType keyboardType;
  List<TextInputFormatter>? formatter;

  switch (type) {
    case InputDialogs.onlyInt:
      formatter = [FilteringTextInputFormatter.digitsOnly];
      keyboardType = TextInputType.number;
      break;
    case InputDialogs.onlyDouble:
      formatter = [FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))];
      keyboardType = TextInputType.number;
      break;
    case InputDialogs.multiLine:
      keyboardType = TextInputType.multiline;
      formatter = null;
      break;
    default:
      formatter = null; // No restrictions on text entry.
      keyboardType = TextInputType.visiblePassword;
  }

  var result = await showDialog<String?>(
    context: context,
    builder: (context) {
      return InputDialog(
        context: context,
        type: type,
        title: title,
        hintText: hintText,
        keyboardType: keyboardType,
        formatter: formatter,
        initialValue: initialValue!,
      );
    },
  );

  if (result == null) return '';

  // Format as a full double, for example text entered as '.49' becomes '0.49'
  // and '5' becomes '5.00'.
  if (type == InputDialogs.onlyDouble) {
    result = double.tryParse(result)?.toStringAsFixed(2).toString();
  }

  return result ?? '';
}

class InputDialog extends StatelessWidget {
  final BuildContext? context;
  final InputDialogs? type;
  final String? title;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatter;

  InputDialog({
    super.key,
    this.context,
    this.type,
    this.title,
    this.hintText,
    this.keyboardType,
    this.formatter,
    required String initialValue,
  }) : maxLines = (type == InputDialogs.multiLine) ? 5 : 1 {
    controller.text = initialValue;
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }

  final FocusNode hotkeyFocusNode = FocusNode();
  final FocusNode textFieldFocusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.enter,
          control: true,
        ): _onSubmitted,
      },
      child: AlertDialog(
        title: (title != null) ? Text(title!) : null,
        content: TextFormField(
          controller: controller,
          focusNode: textFieldFocusNode,
          autofocus: true,
          decoration: InputDecoration(hintText: hintText),
          keyboardType: keyboardType,
          inputFormatters: formatter,
          minLines: 1,
          maxLines: maxLines,
          textInputAction: TextInputAction.newline,
          // For non-multiline fields onFieldSubmitted has enter => submit.
          // For multiline fields the hotkey Ctrl + Enter works instead.
          onFieldSubmitted: (value) =>
              (type == InputDialogs.multiLine) ? null : _onSubmitted(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              AppLocalizations.of(context)!.confirm,
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmitted() {
    if (controller.text == '') {
      Navigator.pop(context!);
    } else {
      Navigator.pop(context!, controller.text);
    }
  }
}
