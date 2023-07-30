import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pase_lista_app/helpers/alerta.dart';

class UbicacionService {
  /**
   * AQUÍ ES DONDE DEBERÁS CONFIGURAR LAS COORDENADAS DE ACUERDO A DONDE TE UBIQUES
   */
  Position? _currentPosition;
  /**Latitud de la ubicación */
  final double _targetLatitude = 17.819565;
  /**Longitud de la ubicación */
  final double _targetLongitude = -92.926933;
  /**Rango máximo de permanencia */
  final double _maxLimitInMeters = 50;

  /** Aquí se le pregunta al usuario si desea habilitar los permisos de ubicación */
  Future<bool> _verPermisosUbicacion(BuildContext context) async {
    LocationPermission permitido = await Geolocator.requestPermission();

    if (permitido == LocationPermission.denied) {
      // ignore: use_build_context_synchronously
      mostrarAlerta(
          context, 'Se requiere ubicación', 'Active los permisos de ubicación');
      return false;
    }

    return true;
  }

  Future<bool> validarUbicacion(BuildContext context) async {
    if (!await _verPermisosUbicacion(context)) return false;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    _currentPosition = position;

    print(_currentPosition);
    print(_targetLatitude);
    print(_targetLongitude);

    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _targetLatitude,
      _targetLongitude,
    );

    print(distanceInMeters);

    /**VERIFICAR SI LA DISTANCIA EN METROS ES MAYOR A _maxLimitInMeters */
    if (distanceInMeters > _maxLimitInMeters) {
      // ignore: use_build_context_synchronously
      mostrarAlerta(
          context, 'Ubicación inválida', 'No puede usar la app en este lugar');
      return false;
    } else {
      return true;
    }
  }
}
