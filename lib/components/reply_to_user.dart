import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReplyToUser extends StatefulWidget {
  final Map<String, dynamic> replyTo;
  final Function sendComment;

  const ReplyToUser({
    super.key,
    required this.replyTo,
    required this.sendComment
  });

  @override
  State<ReplyToUser> createState() => _ReplyToUserState();
}

class _ReplyToUserState extends State<ReplyToUser> {
  final TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Reply To (Optional)
          _buildReplyTo(widget.replyTo),

          // Reply Input
          _buildReplyInput(widget.replyTo),

          // Submit Button
          _buildSubmitButton(widget.sendComment),
        ],
      ),
    );
  }

  Widget _buildReplyTo(Map<String, dynamic> replyTo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(replyTo['avatar']),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(replyTo['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(replyTo['comment'], style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInput(replyTo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _replyController,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: "${'Reply to ' + replyTo['username']}...",
          labelStyle: const TextStyle(color: Colors.grey)
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Function sendComment) {
    print(widget.replyTo['id']);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
              onPressed: () {
                final message = _replyController.text.trim();
                if (message.isNotEmpty) {
                  final parentId = widget.replyTo['id'];
                  sendComment(message, parentId);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: Text(
                  AppLocalizations.of(context)!.sendPost,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
    );
  }
}
