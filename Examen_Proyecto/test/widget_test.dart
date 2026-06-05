import 'package:flutter_test/flutter_test.dart';
import 'package:examen01/main.dart';
import 'package:examen01/data/datasources/local/sql_datasource.dart';
import 'package:examen01/data/datasources/local/nosql_datasource.dart';
import 'package:examen01/data/repositories/content_repository_impl.dart';
import 'package:examen01/presentation/providers/content_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('CineTrackApp smoke test', (WidgetTester tester) async {
    // Mocking/Manual DI for testing
    final sqlDs = SqlDatasource();
    final noSqlDs = NoSqlDatasource();
    final repository = ContentRepositoryImpl(
      sqlDatasource: sqlDs,
      noSqlDatasource: noSqlDs,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ContentProvider(repository),
        child: const CineTrackApp(),
      ),
    );

    // Verifica que el título de la app aparezca (CineTrack)
    expect(find.textContaining('Cine'), findsOneWidget);
    expect(find.textContaining('Track'), findsOneWidget);
  });
}
