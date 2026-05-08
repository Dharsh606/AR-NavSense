// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:ar_navsense/constants/app_constants.dart';

void main() {
  test('AR-NavSense metadata is configured', () {
    expect(AppConstants.appName, 'AR-NavSense');
    expect(AppConstants.tagline, 'Sense the Path. Navigate the World.');
  });
}
