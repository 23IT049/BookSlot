import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/schedule.dart';
import '../models/booking.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  static final CollectionReference _usersCollection = _firestore.collection('users');
  static final CollectionReference _schedulesCollection = _firestore.collection('schedules');
  static final CollectionReference _bookingsCollection = _firestore.collection('bookings');

  // User Operations
  static Future<void> saveUser(User user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  static Future<User?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  static Future<User?> getUserByEmail(String email) async {
    try {
      QuerySnapshot query = await _usersCollection.where('email', isEqualTo: email).get();
      if (query.docs.isNotEmpty) {
        return User.fromJson(query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  static Future<void> updateUser(User user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Schedule Operations
  static Future<void> saveSchedule(Schedule schedule) async {
    try {
      await _schedulesCollection.doc(schedule.id).set(schedule.toJson());
    } catch (e) {
      throw Exception('Failed to save schedule: $e');
    }
  }

  static Future<List<Schedule>> getAllSchedules() async {
    try {
      QuerySnapshot query = await _schedulesCollection.get();
      return query.docs.map((doc) => Schedule.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get schedules: $e');
    }
  }

  static Stream<List<Schedule>> getSchedulesStream() {
    return _schedulesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Schedule.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  static Future<void> updateSchedule(Schedule schedule) async {
    try {
      await _schedulesCollection.doc(schedule.id).update(schedule.toJson());
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  static Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _schedulesCollection.doc(scheduleId).delete();
      // Also delete all bookings for this schedule
      QuerySnapshot bookings = await _bookingsCollection.where('scheduleId', isEqualTo: scheduleId).get();
      for (var doc in bookings.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  // Booking Operations
  static Future<void> saveBooking(Booking booking) async {
    try {
      await _bookingsCollection.doc(booking.id).set(booking.toJson());
    } catch (e) {
      throw Exception('Failed to save booking: $e');
    }
  }

  static Future<List<Booking>> getAllBookings() async {
    try {
      QuerySnapshot query = await _bookingsCollection.get();
      return query.docs.map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  static Stream<List<Booking>> getBookingsStream() {
    return _bookingsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  static Future<List<Booking>> getUserBookings(String userId) async {
    try {
      QuerySnapshot query = await _bookingsCollection.where('userId', isEqualTo: userId).get();
      return query.docs.map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  static Stream<List<Booking>> getUserBookingsStream(String userId) {
    return _bookingsCollection.where('userId', isEqualTo: userId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  static Future<List<Booking>> getScheduleBookings(String scheduleId) async {
    try {
      QuerySnapshot query = await _bookingsCollection.where('scheduleId', isEqualTo: scheduleId).get();
      return query.docs.map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get schedule bookings: $e');
    }
  }

  static Stream<List<Booking>> getScheduleBookingsStream(String scheduleId) {
    return _bookingsCollection.where('scheduleId', isEqualTo: scheduleId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }

  static Future<void> updateBooking(Booking booking) async {
    try {
      await _bookingsCollection.doc(booking.id).update(booking.toJson());
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  static Future<void> deleteBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  // Utility Operations
  static Future<void> initializeSampleData() async {
    try {
      // Check if data already exists
      QuerySnapshot schedules = await _schedulesCollection.limit(1).get();
      if (schedules.docs.isEmpty) {
        // Add sample schedules
        List<Schedule> sampleSchedules = [
          Schedule(
            id: 'schedule_1',
            title: 'Morning Yoga Session',
            description: 'Start your day with refreshing yoga exercises',
            date: DateTime.now().add(const Duration(days: 1)),
            startTime: const TimeOfDay(hour: 7, minute: 0),
            endTime: const TimeOfDay(hour: 8, minute: 0),
            maxParticipants: 20,
            location: 'Fitness Center',
            createdBy: 'admin_1',
          ),
          Schedule(
            id: 'schedule_2',
            title: 'Team Meeting',
            description: 'Weekly team sync and project updates',
            date: DateTime.now().add(const Duration(days: 1)),
            startTime: const TimeOfDay(hour: 10, minute: 0),
            endTime: const TimeOfDay(hour: 11, minute: 30),
            maxParticipants: 15,
            location: 'Conference Room A',
            createdBy: 'admin_1',
          ),
          Schedule(
            id: 'schedule_3',
            title: 'Workshop: Flutter Development',
            description: 'Learn the basics of Flutter app development',
            date: DateTime.now().add(const Duration(days: 2)),
            startTime: const TimeOfDay(hour: 14, minute: 0),
            endTime: const TimeOfDay(hour: 16, minute: 0),
            maxParticipants: 30,
            location: 'Tech Lab',
            createdBy: 'admin_1',
          ),
          Schedule(
            id: 'schedule_4',
            title: 'Evening Meditation',
            description: 'Relax and unwind with guided meditation',
            date: DateTime.now().add(const Duration(days: 2)),
            startTime: const TimeOfDay(hour: 18, minute: 0),
            endTime: const TimeOfDay(hour: 19, minute: 0),
            maxParticipants: 25,
            location: 'Wellness Room',
            createdBy: 'admin_1',
          ),
        ];

        for (var schedule in sampleSchedules) {
          await saveSchedule(schedule);
        }
      }

      // Check if admin user exists
      DocumentSnapshot adminDoc = await _usersCollection.doc('admin_1').get();
      if (!adminDoc.exists) {
        User admin = User(
          id: 'admin_1',
          name: 'Admin User',
          email: 'admin@bookslot.com',
          password: 'admin123', // In production, use proper authentication
          isAdmin: true,
        );
        await saveUser(admin);
      }

      // Check if sample user exists
      DocumentSnapshot userDoc = await _usersCollection.doc('user_1').get();
      if (!userDoc.exists) {
        User sampleUser = User(
          id: 'user_1',
          name: 'Test User',
          email: 'user@bookslot.com',
          password: 'user123', // In production, use proper authentication
          isAdmin: false,
        );
        await saveUser(sampleUser);
      }
    } catch (e) {
      throw Exception('Failed to initialize sample data: $e');
    }
  }
}
