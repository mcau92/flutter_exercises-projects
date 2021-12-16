import 'package:flutter/material.dart';

class NavigationService {
  GlobalKey<NavigatorState> navigatorKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigatorKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String _routeName) {
    return navigatorKey.currentState.pushReplacementNamed(_routeName);
  }

  Future<dynamic> navigateTo(String _routeName) {
    return navigatorKey.currentState.pushNamed(_routeName);
  }

  Future<dynamic> navigateToWithParameters(
      String _routeName, Object arguments) {
    return navigatorKey.currentState
        .pushNamed(_routeName, arguments: arguments);
  }

  Future<dynamic> navigateToReplacementWithParameters(
      String _routeName, Object arguments) {
    return navigatorKey.currentState
        .pushReplacementNamed(_routeName, arguments: arguments);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _route) {
    return navigatorKey.currentState.push(_route);
  }

  void goBack() {
    return navigatorKey.currentState.pop();
  }

  void goBackUntil(String route) {
    return navigatorKey.currentState.popUntil(ModalRoute.withName(route));
  }
}
