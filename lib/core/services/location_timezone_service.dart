import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationTimezoneServiceProvider = Provider<LocationTimezoneService>((
  ref,
) {
  return LocationTimezoneService();
});

class LocationTimezoneService {
  LocationTimezoneService();

  Future<String> resolveTimezone() async {
    // Tests or headless environments: bypass native platform channels
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return getDeviceTimezone();
    }

    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return getDeviceTimezone();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return getDeviceTimezone();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 4),
          accuracy: LocationAccuracy.low,
        ),
      );

      final tz = getTimezoneFromCoordinates(
        position.latitude,
        position.longitude,
      );
      return tz;
    } catch (e) {
      debugPrint('LocationTimezoneService resolve error: $e');
      return getDeviceTimezone();
    }
  }

  String getTimezoneFromCoordinates(double lat, double lng) {
    // India & Subcontinent
    if (lat >= 6.0 && lat <= 38.0 && lng >= 68.0 && lng <= 98.0) {
      return 'Asia/Kolkata';
    }

    // North America
    if (lat >= 24.0 && lat <= 72.0) {
      if (lng >= -170.0 && lng < -130.0) return 'America/Anchorage';
      if (lng >= -130.0 && lng < -114.0) return 'America/Los_Angeles';
      if (lng >= -114.0 && lng < -102.0) return 'America/Denver';
      if (lng >= -102.0 && lng < -85.0) return 'America/Chicago';
      if (lng >= -85.0 && lng <= -50.0) return 'America/New_York';
    }

    // Europe
    if (lat >= 35.0 && lat <= 71.0) {
      if (lng >= -11.0 && lng < 2.0) return 'Europe/London';
      if (lng >= 2.0 && lng < 25.0) return 'Europe/Paris';
      if (lng >= 25.0 && lng <= 45.0) return 'Europe/Athens';
    }

    // East Asia
    if (lat >= 20.0 && lat <= 50.0 && lng >= 120.0 && lng <= 145.0) {
      return 'Asia/Tokyo';
    }

    // Australia
    if (lat >= -45.0 && lat <= -10.0 && lng >= 110.0 && lng <= 155.0) {
      return 'Australia/Sydney';
    }

    // Rough approximation based on longitude
    final hours = (lng / 15.0).round();
    if (hours == 0) return 'UTC';
    final sign = hours >= 0 ? '+' : '-';
    final pad = hours.abs().toString().padLeft(2, '0');
    return 'UTC$sign$pad:00';
  }

  String getDeviceTimezone() {
    final name = DateTime.now().timeZoneName;
    final offset = DateTime.now().timeZoneOffset;

    if (name.contains('/')) return name;

    switch (name.toUpperCase()) {
      case 'IST':
        return 'Asia/Kolkata';
      case 'EST':
      case 'EDT':
        return 'America/New_York';
      case 'CST':
      case 'CDT':
        return 'America/Chicago';
      case 'MST':
      case 'MDT':
        return 'America/Denver';
      case 'PST':
      case 'PDT':
        return 'America/Los_Angeles';
      case 'GMT':
      case 'BST':
      case 'WET':
        return 'Europe/London';
      case 'CET':
      case 'CEST':
        return 'Europe/Paris';
      case 'EET':
      case 'EEST':
        return 'Europe/Athens';
      case 'JST':
      case 'KST':
        return 'Asia/Tokyo';
      case 'AEST':
      case 'AEDT':
        return 'Australia/Sydney';
    }

    final totalMinutes = offset.inMinutes;
    if (totalMinutes == 330) return 'Asia/Kolkata';
    if (totalMinutes == -300 || totalMinutes == -240) return 'America/New_York';
    if (totalMinutes == -360 || totalMinutes == -300) return 'America/Chicago';
    if (totalMinutes == -420 || totalMinutes == -360) return 'America/Denver';
    if (totalMinutes == -480 || totalMinutes == -420) {
      return 'America/Los_Angeles';
    }
    if (totalMinutes == 0 || totalMinutes == 60) return 'Europe/London';
    if (totalMinutes == 540) return 'Asia/Tokyo';
    if (totalMinutes == 600 || totalMinutes == 660) return 'Australia/Sydney';

    final sign = offset.isNegative ? '-' : '+';
    final absHours = offset.inHours.abs().toString().padLeft(2, '0');
    final absMins = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return 'UTC$sign$absHours:$absMins';
  }

  Duration getOffsetForTimezone(String? timezone) {
    if (timezone == null || timezone.isEmpty) {
      return DateTime.now().timeZoneOffset;
    }

    switch (timezone) {
      case 'Asia/Kolkata':
      case 'Asia/Calcutta':
        return const Duration(hours: 5, minutes: 30);
      case 'America/New_York':
        return const Duration(hours: -5);
      case 'America/Chicago':
        return const Duration(hours: -6);
      case 'America/Denver':
        return const Duration(hours: -7);
      case 'America/Los_Angeles':
        return const Duration(hours: -8);
      case 'America/Anchorage':
        return const Duration(hours: -9);
      case 'Europe/London':
        return Duration.zero;
      case 'Europe/Paris':
        return const Duration(hours: 1);
      case 'Europe/Athens':
        return const Duration(hours: 2);
      case 'Asia/Tokyo':
        return const Duration(hours: 9);
      case 'Australia/Sydney':
        return const Duration(hours: 10);
      case 'UTC':
        return Duration.zero;
    }

    if (timezone.startsWith('UTC+') || timezone.startsWith('UTC-')) {
      final sign = timezone[3] == '+' ? 1 : -1;
      final parts = timezone.substring(4).split(':');
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      return Duration(minutes: sign * (hours * 60 + minutes));
    }

    return DateTime.now().timeZoneOffset;
  }

  DateTime nextDailyMidnight({String? timezone, DateTime? now}) {
    final current = now?.toUtc() ?? DateTime.now().toUtc();
    final offset = getOffsetForTimezone(timezone);
    final local = current.add(offset);
    final localNextMidnight = DateTime.utc(
      local.year,
      local.month,
      local.day + 1,
      0,
      0,
      0,
    );
    return localNextMidnight.subtract(offset);
  }

  DateTime nextWeeklySundayMidnight({String? timezone, DateTime? now}) {
    final current = now?.toUtc() ?? DateTime.now().toUtc();
    final offset = getOffsetForTimezone(timezone);
    final local = current.add(offset);
    var daysUntilSunday = DateTime.sunday - local.weekday;
    if (daysUntilSunday <= 0) {
      daysUntilSunday += 7;
    }
    final localNextSunday = DateTime.utc(
      local.year,
      local.month,
      local.day + daysUntilSunday,
      0,
      0,
      0,
    );
    return localNextSunday.subtract(offset);
  }
}
