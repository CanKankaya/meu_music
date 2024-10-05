import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Mask to be used for a phone number input
var phoneMaskFormatter = MaskTextInputFormatter(
  mask: '### ### ## ##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

//* Changed from String to String? to avoid null safety issues
//* Check for problems later
extension StringExtensions on String? {
  String removeSpaces() {
    // Remove all spaces from the text
    if (this == null) return '';
    return this!.replaceAll(RegExp(r'\s+'), '');
  }

  String removeNonDigits() {
    // Remove all non-digit characters from the text
    if (this == null) return '';
    return this!.replaceAll(RegExp(r'\D'), '');
  }

  String removeSeparators(String separator) {
    // Function that returns the number without the mask to send to API
    if (this == null) return '';
    return this!.replaceAll(separator, '');
  }

  String formatWithMask(String format) {
    // Function that formats a given string with the specified mask
    if (this == null || this == '') return '';
    var mask = format;
    int strIndex = 0;
    for (int i = 0; i < mask.length; i++) {
      if (mask[i] == 'x' && strIndex < this!.length) {
        mask = mask.replaceFirst('x', this![strIndex]);
        strIndex++;
      }
    }
    return mask;
  }

  String capitalizeFirstLetterOfEachWord() {
    // Capitalize the first letter of each word and make the rest lowercase
    if (this == null) return '';
    return this!.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
