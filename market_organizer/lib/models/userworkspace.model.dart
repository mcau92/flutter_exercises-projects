import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/spesa.dart';



class UserWorkspace {
  String id;
  String name;
  String ownerId;
  List<String> contributorsId;
  bool focused; //last user selected workspace on homepage
  List<String> spesaIdsRef;
  List<String> menuIdsRef;

  UserWorkspace({
    this.id,
    this.name,
    this.ownerId,
    this.contributorsId,
    this.focused,
    this.spesaIdsRef,
    this.menuIdsRef,
  });

  factory UserWorkspace.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();

    
    return UserWorkspace(
      id: _snapshot.id,
      name: _data["name"],
      ownerId: _data["ownerId"],
      contributorsId: _data["contributorsId"].cast<String>(),
      focused: _data["focused"],
      spesaIdsRef: _data["spesaIdsRef"].cast<String>(),
      menuIdsRef: _data["menuIdsRef"].cast<String>(),
    );
  }
}
