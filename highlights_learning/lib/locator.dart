import 'package:get_it/get_it.dart';
import 'package:highlights_learning/api/api.dart';
import 'package:highlights_learning/provider/highlights_provider.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => Api('highlight'));
  locator.registerLazySingleton(() => HighlightsProvider());
}
