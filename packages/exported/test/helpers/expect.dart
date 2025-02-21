import 'package:test/test.dart';

void expectArgumentError(dynamic Function() function) {
  expect(function, throwsArgumentError);
}
