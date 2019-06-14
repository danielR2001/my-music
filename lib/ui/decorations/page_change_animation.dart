import 'package:flutter/material.dart';

class MyCustomRouteAnimation extends MaterialPageRoute {
  MyCustomRouteAnimation({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
        Animation<Offset> custom = Tween<Offset>(begin: Offset(0.0,1.0),end: Offset(0.0,0.0)).animate(animation);
        return SlideTransition(position: custom,child: child,);
  }
}