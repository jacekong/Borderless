import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReplyComment extends StatefulWidget {
  final Map<String, dynamic> originalPost;
  final Function sendMessage;

  const ReplyComment({
    super.key,
    required this.originalPost,
    required this.sendMessage,
  });

  @override
  State<ReplyComment> createState() => _ReplyCommentState();
}

class _ReplyCommentState extends State<ReplyComment> {
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
          _buildOriginalPost(widget.originalPost),

          // Reply Input
          _buildReplyInput(widget.originalPost),

          // Submit Button
          _buildSubmitButton(widget.sendMessage),
        ],
      ),
    );
  }

  Widget _buildOriginalPost(Map<String, dynamic> post) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(post['avatar']),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(post['content']),
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

  Widget _buildSubmitButton(Function sendMessage) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
              onPressed: () {
                String reply = _replyController.text.trim();
                if (reply.isNotEmpty) {
                  sendMessage(_replyController.text.trim());
                  Navigator.pop(context);
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
