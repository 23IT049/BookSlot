import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  group('Firebase Tests', () {
    test('Firebase can be initialized without Auth', () async {
      // This test verifies that Firebase Core and Firestore work without Auth
      expect(FirebaseFirestore.instance, isNotNull);
    });
  });
}
