import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cam_route_ia/app/app.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('CAM-ROUTE IA démarre', (tester) async {
    await tester.pumpWidget(const CamRouteApp());
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
