import 'package:flutter_test/flutter_test.dart';
import 'package:bookslot/providers/auth_provider.dart';
import 'package:bookslot/providers/booking_provider.dart';

void main() {
  group('Compilation Tests', () {
    test('AuthProvider can be instantiated', () {
      expect(() => AuthProvider(), returnsNormally);
    });

    test('BookingProvider can be instantiated', () {
      expect(() => BookingProvider(), returnsNormally);
    });
  });
}
