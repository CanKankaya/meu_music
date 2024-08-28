import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Mask to be used for a phone number input
var phoneMaskFormatter = MaskTextInputFormatter(
  mask: '### ### ## ##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

// class MaskedTextInputFormatter extends TextInputFormatter {
//   final String mask;
//   final String separator;
//   MaskedTextInputFormatter({
//     required this.mask,
//     required this.separator,
//   });
//   @override
//   TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
//     if (newValue.text.isNotEmpty) {
//       if (newValue.text.length > oldValue.text.length) {
//         if (newValue.text.length > mask.length) return oldValue;
//         if (newValue.text.length < mask.length && mask[newValue.text.length - 1] == separator) {
//           return TextEditingValue(
//             text: '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
//             selection: TextSelection.collapsed(
//               offset: newValue.selection.end + 1,
//             ),
//           );
//         }
//       }
//     }
//     return newValue;
//   }
// }

//Function that returns the number without the mask to send to API
String removeSeparators(String seperator, String str) {
  return str.replaceAll(seperator, '');
}

// Function that formats a given string with the specified mask
String formatWithMask(String format, String str) {
  if (str == '') return '';
  var mask = format;
  int strIndex = 0;
  for (int i = 0; i < mask.length; i++) {
    if (mask[i] == 'x' && strIndex < str.length) {
      mask = mask.replaceFirst('x', str[strIndex]);
      strIndex++;
    }
  }
  return mask;
}
