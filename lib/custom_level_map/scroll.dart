import 'package:flutter/material.dart';

class MyBehavior extends ScrollBehavior {
  const MyBehavior();
  @override
  // ignore: override_on_non_overriding_member
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}