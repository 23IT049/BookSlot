import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/schedule.dart';
import '../models/booking.dart';
import '../models/user.dart';

class BookingProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Schedule> get schedules => _schedules;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookingProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      final schedulesJson = prefs.getStringList('schedules') ?? [];
      _schedules = schedulesJson
          .map((json) => Schedule.fromJson(jsonDecode(json)))
          .toList();

      if (_schedules.isEmpty) {
        _schedules = _generateSampleSchedules();
        await _saveSchedules();
      }

      final bookingsJson = prefs.getStringList('bookings') ?? [];
      _bookings = bookingsJson
          .map((json) => Booking.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Schedule> _generateSampleSchedules() {
    final now = DateTime.now();
    return [
      Schedule(
        id: 'schedule_1',
        title: 'Morning Yoga Session',
        description: 'Start your day with refreshing yoga exercises',
        date: DateTime(now.year, now.month, now.day + 1),
        startTime: TimeOfDay(hour: 7, minute: 0),
        endTime: TimeOfDay(hour: 8, minute: 0),
        maxParticipants: 20,
        location: 'Fitness Center',
        createdBy: 'admin_1',
      ),
      Schedule(
        id: 'schedule_2',
        title: 'Team Meeting',
        description: 'Weekly team sync and project updates',
        date: DateTime(now.year, now.month, now.day + 1),
        startTime: TimeOfDay(hour: 10, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 30),
        maxParticipants: 15,
        location: 'Conference Room A',
        createdBy: 'admin_1',
      ),
      Schedule(
        id: 'schedule_3',
        title: 'Workshop: Flutter Development',
        description: 'Learn the basics of Flutter app development',
        date: DateTime(now.year, now.month, now.day + 2),
        startTime: TimeOfDay(hour: 14, minute: 0),
        endTime: TimeOfDay(hour: 16, minute: 0),
        maxParticipants: 30,
        location: 'Tech Lab',
        createdBy: 'admin_1',
      ),
      Schedule(
        id: 'schedule_4',
        title: 'Evening Meditation',
        description: 'Relax and unwind with guided meditation',
        date: DateTime(now.year, now.month, now.day + 2),
        startTime: TimeOfDay(hour: 18, minute: 0),
        endTime: TimeOfDay(hour: 19, minute: 0),
        maxParticipants: 25,
        location: 'Wellness Room',
        createdBy: 'admin_1',
      ),
    ];
  }

  Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = _schedules.map((schedule) => json.encode(schedule.toJson())).toList();
      await prefs.setStringList('schedules', schedulesJson);
    } catch (e) {
      _errorMessage = 'Failed to save schedules';
    }
  }

  Future<void> _saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = _bookings.map((booking) => json.encode(booking.toJson())).toList();
      await prefs.setStringList('bookings', bookingsJson);
    } catch (e) {
      _errorMessage = 'Failed to save bookings';
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedules.add(schedule);
      await _saveSchedules();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add schedule';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _schedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _schedules[index] = schedule;
        await _saveSchedules();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update schedule';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _schedules.removeWhere((s) => s.id == scheduleId);
      _bookings.removeWhere((b) => b.scheduleId == scheduleId);
      await _saveSchedules();
      await _saveBookings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete schedule';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookSchedule(String userId, String scheduleId, {String? notes}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final schedule = _schedules.firstWhere((s) => s.id == scheduleId);
      
      if (!schedule.isAvailable) {
        _errorMessage = 'This schedule is no longer available';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final existingBooking = _bookings.any((b) => 
          b.userId == userId && b.scheduleId == scheduleId);
      
      if (existingBooking) {
        _errorMessage = 'You have already booked this schedule';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final booking = Booking(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        scheduleId: scheduleId,
        bookingTime: DateTime.now(),
        notes: notes,
      );

      _bookings.add(booking);

      final scheduleIndex = _schedules.indexWhere((s) => s.id == scheduleId);
      if (scheduleIndex != -1) {
        _schedules[scheduleIndex] = _schedules[scheduleIndex].copyWith(
          currentParticipants: _schedules[scheduleIndex].currentParticipants + 1,
        );
      }

      await _saveBookings();
      await _saveSchedules();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to book schedule';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = _bookings.firstWhere((b) => b.id == bookingId);
      
      _bookings.removeWhere((b) => b.id == bookingId);

      final scheduleIndex = _schedules.indexWhere((s) => s.id == booking.scheduleId);
      if (scheduleIndex != -1) {
        _schedules[scheduleIndex] = _schedules[scheduleIndex].copyWith(
          currentParticipants: _schedules[scheduleIndex].currentParticipants - 1,
        );
      }

      await _saveBookings();
      await _saveSchedules();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to cancel booking';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Booking> getUserBookings(String userId) {
    return _bookings.where((b) => b.userId == userId).toList();
  }

  List<Booking> getScheduleBookings(String scheduleId) {
    return _bookings.where((b) => b.scheduleId == scheduleId).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
