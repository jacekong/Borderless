import 'package:borderless/api/api_service.dart';
import 'package:borderless/model/friend_request_status.dart';
import 'package:borderless/model/user_profile.dart';
import 'package:borderless/provider/friend_request_provider.dart';
import 'package:borderless/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserDetailPage extends StatelessWidget {
  final UserProfile user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userDetail),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user.avatar),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 5,
              child: Text(
                user.username,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Roboto'),
              ),
            ),
            SizedBox(width: screenWidth * 0.2),
            Expanded(
              flex: 5,
              child: Consumer<FriendRequestStatusProvider>(
                builder: (_, statusProvider, __) {
                  FriendRequestStatus status = statusProvider.getStatus();
                  bool isFriendRequestSent =
                      status.isFriendRequestSent(user.id);
                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.green; // Color when the button is pressed
                          }
                          return Colors.blue; // Default color
                        },
                      ),
                    ),
                    onPressed: () {
                      if (isFriendRequestSent) {
                        // Cancel friend request
                        _cancelFriendRequest(context, user.id);
                      } else {
                        // Send friend request
                        _sendFriendRequest(context, user.id);
                      }
                    },
                    child: Text(
                      isFriendRequestSent ? AppLocalizations.of(context)!.cancel : AppLocalizations.of(context)!.addFriend,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFriendRequest(BuildContext context, String userId) async {
    try {
      await ApiService.addFriend(context, userId);
      if (context.mounted) {
        Provider.of<FriendRequestStatusProvider>(context, listen: false)
            .setFriendRequestSent(userId, true);
      }
      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          message: "請求發送成功",
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          message: "$e",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // cancel
  Future<void> _cancelFriendRequest(BuildContext context, String userId) async {
    try {
      await ApiService.cancelFriendRequest(userId);
      if (context.mounted) {
        Provider.of<FriendRequestStatusProvider>(context, listen: false)
            .setFriendRequestSent(userId, true);
      }
      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          message: "取消成功",
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        CustomSnackbar.show(
          context: context,
          message: "$e",
          backgroundColor: Colors.red,
        );
      }
    }
  }
}
