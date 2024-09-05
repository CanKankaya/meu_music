import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Mask to be used for a phone number input
var phoneMaskFormatter = MaskTextInputFormatter(
  mask: '### ### ## ##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

extension StringExtensions on String {
  String removeSpaces() {
    // Remove all spaces from the text
    return replaceAll(RegExp(r'\s+'), '');
  }

  String removeNonDigits() {
    // Remove all non-digit characters from the text
    return replaceAll(RegExp(r'\D'), '');
  }

  String removeSeparators(String separator) {
    // Function that returns the number without the mask to send to API
    return replaceAll(separator, '');
  }

  String formatWithMask(String format) {
    // Function that formats a given string with the specified mask
    if (this == '') return '';
    var mask = format;
    int strIndex = 0;
    for (int i = 0; i < mask.length; i++) {
      if (mask[i] == 'x' && strIndex < length) {
        mask = mask.replaceFirst('x', this[strIndex]);
        strIndex++;
      }
    }
    return mask;
  }
}
