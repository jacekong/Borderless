import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:borderless/main.dart';
import 'package:borderless/utils/utils.dart';
import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';

class NotificationController {
  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: 'basic_channel_nitification',
              channelName: 'notification',
              channelDescription: 'Message Notifications',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> createNewNotification(String sender, String notification, String avatar, String messageType) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale(navigatorKey);
    if (!isAllowed) return;

    if (messageType == 'text') {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: UniqueId.createUniqueId(),
            channelKey: 'basic_channel_nitification',
            title: sender,
            body: notification,
            // bigPicture: avatar,
            largeIcon: 'https://$avatar',
            // notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),);
    } else if (messageType == 'image') {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: UniqueId.createUniqueId(),
            channelKey: 'basic_channel_nitification',
            title: sender,
            body: '$sender 向你發了一張圖片',
            bigPicture: 'https://$notification',
            largeIcon: 'https://$avatar',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),);
    } else if (messageType == 'audio') {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: UniqueId.createUniqueId(),
            channelKey: 'basic_channel_nitification',
            title: sender,
            body: '收到一條來自“$sender”的語音訊息',
            bigPicture: '',
            largeIcon: 'https://$avatar',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),);
    }

        // actionButtons: [
        //   NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
        //   NotificationActionButton(
        //       key: 'REPLY',
        //       label: 'Reply Message',
        //       requireInputText: true,
        //       actionType: ActionType.SilentAction),
        //   NotificationActionButton(
        //       key: 'DISMISS',
        //       label: 'Dismiss',
        //       actionType: ActionType.DismissAction,
        //       isDangerousOption: true)
        // ]
  
  }
  
  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }
  
   ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale(context) async {
    bool userAuthorized = false;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    '可以及時向你發送通知📢'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

}
