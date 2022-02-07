import 'package:market_organizer/models/product_model.dart';

class ProductInputForDb {
  final Product product;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String workspaceId;

  ProductInputForDb(
      this.product, this.dateStart, this.dateEnd, this.workspaceId);
}
