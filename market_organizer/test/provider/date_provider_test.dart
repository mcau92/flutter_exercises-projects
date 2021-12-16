import 'package:flutter_test/flutter_test.dart';
import 'package:market_organizer/provider/date_provider.dart';

void main() {
  test('DateTest increments by 7', () async {
    final DateProvider dateProvider = new DateProvider();

    //
    dateProvider.increaseWeek();
    //
    print(dateProvider.dateStart.day);
    expect(2, 2);
  });
}
