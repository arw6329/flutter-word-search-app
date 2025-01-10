import 'package:flutter/material.dart';

class LargeCommonButton extends StatelessWidget {
    const LargeCommonButton({super.key, required this.onPressed, this.child, this.color, this.solid = true});

    final void Function() onPressed;
    final Widget? child;
    final Color? color;
    final bool solid;

    @override
    Widget build(BuildContext context) {
        return ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                backgroundColor: solid ? color ?? Theme.of(context).colorScheme.primary : Colors.transparent,
                foregroundColor: solid ? Color.fromRGBO(22, 22, 22, 0.7) : color ?? Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                textStyle: TextStyle(
                    fontSize: 20
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)
                ),
                side: solid ? null : BorderSide(
                    color: color ?? Colors.white,
                    width: 2
                )
            ),
            child: child
        );
    }
}