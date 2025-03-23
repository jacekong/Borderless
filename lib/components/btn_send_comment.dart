// import 'package:flutter/material.dart';

// class BtnSendComment extends StatelessWidget {
//   const BtnSendComment({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 7),
//                 decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         cursorColor: Colors.black,
//                         maxLines: null,
//                         controller: _textEditingController,
//                         style: const TextStyle(color: Colors.black),
//                         decoration: InputDecoration(
//                             focusColor: Theme.of(context).colorScheme.secondary,
//                             hoverColor: Theme.of(context).colorScheme.secondary,
//                             border: InputBorder.none,
//                             hintText: AppLocalizations.of(context)!.comment,
//                             hintStyle: const TextStyle(
//                                 color: Colors.grey, fontSize: 15)),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(
//                         Icons.send,
//                         color: Colors.blue,
//                       ),
//                       onPressed: () {
//                         _sendMessage();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//   }
// }