import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pase_lista_app/helpers/alerta.dart';
import 'package:pase_lista_app/variables/api.dart';

class UbicacionService {
  /**
   * AQUÍ ES DONDE DEBERÁS CONFIGURAR LAS COORDENADAS DE ACUERDO A DONDE TE UBIQUES
   */
  Position? _currentPosition;

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
    print("Validando ubicación");
    if (!await _verPermisosUbicacion(context)) return false;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    _currentPosition = position;

    Response respuesta = await Dio().get(API_URL + "/ubicaciones/actual");

    var ubicacionAPI = respuesta.data["data"];
    print(ubicacionAPI);
    /**Latitud de la ubicación */
    var _targetLatitude = double.parse(ubicacionAPI["latitud"]);
    /**Longitud de la ubicación */
    var _targetLongitude = double.parse(ubicacionAPI["longitud"]);
    /**Rango máximo de permanencia */
    var _maxLimitInMeters = (ubicacionAPI["rango"]);

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
