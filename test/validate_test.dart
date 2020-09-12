import 'package:flutter_test/flutter_test.dart';
import 'validate_form.dart';

void main() {
  final formKey = true;
  test('validate form should return false', () {
    final counter = validateform();
    counter.validateAndSave();
    expect(counter, true);
  });
}


