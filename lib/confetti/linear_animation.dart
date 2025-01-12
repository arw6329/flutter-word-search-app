import 'package:flutter/material.dart';

AnimationController startLinearAnimation<T>({
    required TickerProvider provider,
    required Duration duration,
    required void Function(T) callback,
    required T start,
    required T end,
    bool repeat = false
}) {
    var controller = AnimationController(
        vsync: provider,
        duration: duration,
    );

    var animation = controller.drive(
        Tween<T>(
            begin: start,
            end: end
        )
    );

    animation.addListener(() {
        callback(animation.value);
    });

    if(repeat) {
        controller.repeat();
    } else {
        controller.forward();
    }

    return controller;
}