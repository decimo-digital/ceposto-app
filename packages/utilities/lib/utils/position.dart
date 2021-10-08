import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mutex/mutex.dart';

/// Utility che espone API per il recupero della posizione
/// del device
class PositionService {
  // ignore: public_member_api_docs
  factory PositionService() => _instance;
  PositionService._internal();
  static final PositionService _instance = PositionService._internal();

  /// Usato per evitare di mandare infinite richieste alla localizzazione
  static final _mutex = Mutex();

  /// Contiene l'ultima posizione recuperata
  LatLng? _lastPosition;

  /// Indica se per questa esecuzione dell'app è già stato richiesto il
  /// permesso all'utilizzo della posizione
  bool _requested = false;

  /// Ritorna `true` se il [Geolocator] sta richiedendo i permessi per la
  /// localizzazione
  bool get isRequestingPermission => _mutex.isLocked;

  /// Recupera l'ultima posizione nota, se c'è
  LatLng? get lastPositionSync {
    if (_lastPosition == null) {
      debugPrint(
        '[PositionService] Requested lastPositionSync but it was null',
      );
      lastPosition;
    }

    return _lastPosition;
  }

  /// Recupera l'ultima posizione nota e aggiorna lo stato di [_lastPosition]
  Future<LatLng?> get lastPosition async {
    Position? position;

    await _mutex.acquire();
    if (await Geolocator.checkPermission() == LocationPermission.denied) {
      _mutex.release();
      return null;
    }
    position = await Geolocator.getLastKnownPosition()
        .onError((error, stackTrace) => null);
    _mutex.release();

    try {
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            timeLimit: const Duration(seconds: 3),
          );
        } catch (e) {
          debugPrint('[PositionService] getCurrentPosition failed: $e');
          return null;
        }
        debugPrint('[PositionService] Got currentPosition');
        return _lastPosition = LatLng(position.latitude, position.longitude);
      } else {
        debugPrint('[PositionService] Got lastKnownPosition');
        return _lastPosition = LatLng(position.latitude, position.longitude);
      }
    } finally {
      Geolocator.getCurrentPosition().then(
        (_) => debugPrint('[PositionService] Updated current position'),
      );
    }
  }

  /// Richiede i permessi per accedere alla localizzazione
  ///
  /// Se vengono accettati, aggiorna [_lastPosition]
  Future<void> requestPermission() async {
    if (_requested) return;

    await _mutex.acquire();
    _requested = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          // ignore: lines_longer_than_80_chars
          'Location permissions are permantly denied, we cannot request permissions.',
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        try {
          permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.whileInUse &&
              permission != LocationPermission.always) {
            debugPrint('Locations permissions were denied');
            return;
          }
        } catch (e) {
          debugPrint('[PositionService] Request permission error: $e');
          debugPrintStack(stackTrace: StackTrace.current);
        }
      }

      await Geolocator.getCurrentPosition().then(
        (position) =>
            _lastPosition = LatLng(position.latitude, position.longitude),
      );
    } finally {
      _mutex.release();
    }
  }

  /// Formatta la distanza in modo compatto
  static String formatDistance(num? distance) {
    if (distance == null || distance == -1) return '> 4000 km';

    int kms = 0;
    int mts;
    if (distance >= 1000) kms = distance ~/ 1000;
    mts = (distance - (kms * 1000)).round();

    var formatted = '';
    if (kms > 0) {
      formatted = '$kms';
      if (mts > 100) formatted += ',${mts.toString().substring(0, 2)}';
      formatted += ' km';
    } else {
      formatted = '$mts m';
    }

    return formatted;
  }
}
