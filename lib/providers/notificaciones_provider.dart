import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pase_lista_app/helpers/alerta.dart';
import 'package:permission_handler/permission_handler.dart';

/**Servicio para disparar notificaciones push */
class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<bool> solicitarPermisos(BuildContext context) async {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      return true;
    } else {
      mostrarAlerta(context, 'Se requiere usar las notificaciones',
          'Active los permisos de notificación');
      return false;
    }
  }

  Future<void> iniciarNotificaciones() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('flutter_logo');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  _detallesNotificaciones() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('pase-lista', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future enviarNotificacion(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await _detallesNotificaciones());
  }
}
