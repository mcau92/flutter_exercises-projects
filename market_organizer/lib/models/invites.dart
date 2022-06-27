import 'package:cloud_firestore/cloud_firestore.dart';

class Invites {
  final String? id;
  final String? email; //used only if user not exist already in app
  final String? userId;
  final String? accepted; //could be null if not already decided
  final DateTime? dateInvitation;

  Invites({
    this.id,
    this.email,
    this.userId,
    this.accepted,
    this.dateInvitation,
  });

  factory Invites.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;
    print(_data["email"]);
    return Invites(
      id: _snapshot.id,
      email: _data["email"],
      userId: _data["userId"],
      accepted: _data["accepted"],
      dateInvitation: _data["dateInvitation"].toDate(),
    );
  }
}
