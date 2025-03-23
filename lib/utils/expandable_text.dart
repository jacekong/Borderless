import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLength;

  const ExpandableText({super.key, required this.text, this.maxLength = 90});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isTextLong = widget.text.length > widget.maxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isExpanded
              ? widget.text
              : widget.text.length > widget.maxLength
                  ? '${widget.text.substring(0, widget.maxLength)}...'
                  : widget.text,
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isTextLong)
          TextButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(0),
              alignment: Alignment.topRight,
            ),
            child: Text(
              isExpanded ? "Show Less" : "Show More",
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          ],
        )
      ],
    );
  }
}