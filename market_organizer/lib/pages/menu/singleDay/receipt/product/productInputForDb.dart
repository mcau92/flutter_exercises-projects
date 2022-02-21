import 'package:market_organizer/models/product_model.dart';

class ProductInputForDb {
  final Product product;
  final String workspaceId;

  ProductInputForDb(this.product, this.workspaceId);
}
