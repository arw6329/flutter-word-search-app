import 'dart:math';
import 'package:vector_math/vector_math_64.dart' as vec;

int positiveOrNegative() {
    return Random().nextBool() ? -1 : 1;
}

vec.Vector3 randomVector3Normalized() {
    final vector = vec.Vector3.random();
    return vec.Vector3(
        vector.x * positiveOrNegative(),
        vector.y * positiveOrNegative(),
        vector.z * positiveOrNegative()
    ).normalized();
}

vec.Vector2 randomPositiveVector2Normalized() {
    return vec.Vector2.random().normalized();
}