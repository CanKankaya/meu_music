import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onPressed,
  }) : super(key: key);
  final String text;
  final Icon? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        onPressed: onPressed,
        color: backgroundColor ?? Colors.amber,
        disabledColor: const Color.fromARGB(255, 51, 51, 51),
        child: Row(
          children: [
            const Spacer(),
            icon ?? const SizedBox(),
            if (icon != null) const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
