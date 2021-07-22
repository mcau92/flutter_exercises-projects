import 'package:market_organizer/models/userworkspace.model.dart';

class Utils {
  static Utils instance = Utils();

  List<String> getReparti(UserWorkspace workspace) {
    List<String> reparti = [];
    workspace.products.forEach((element) {
      if (!reparti.contains(element.reparto)) {
        reparti.add(element.reparto);
      }
    });
    return reparti;
  }
}
