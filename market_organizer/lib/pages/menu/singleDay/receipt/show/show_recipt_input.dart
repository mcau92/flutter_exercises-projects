import 'package:market_organizer/models/ricetta.dart';

class ShowReceiptInput {
  String workspaceId;
  final Ricetta ricetta;

  ShowReceiptInput(this.workspaceId, this.ricetta);
}
