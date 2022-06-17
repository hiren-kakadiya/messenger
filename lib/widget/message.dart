import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key? key,
    required this.text,
    required this.isCurrentUser,
    required this.time,
    required this.seen,
    required this.isConnected,
  }) : super(key: key);
  final String text, time;
  final bool isCurrentUser, seen, isConnected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // asymmetric padding
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? 64.0 : 16.0,
        4,
        isCurrentUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        // align the child within the container
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: DecoratedBox(
          // chat bubble decoration
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.teal : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: isCurrentUser ? Colors.white : Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      time,
                      style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black87),
                    ),
                  ),
                  checkMethod(),
                ],
              )),
        ),
      ),
    );
  }

  Widget checkMethod() {
    if (isCurrentUser) {
      if (isConnected) {
        if (seen) {
          return Padding(
            padding: const EdgeInsets.only(left: 5),
            child: SizedBox(
              height: 20,
              width: 20,
              child: Image.asset('assets/images/double-check.png'),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(left: 5),
            child: SizedBox(
              height: 20,
              width: 20,
              child: Image.asset('assets/images/double-tick.png'),
            ),
          );
        }
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 5),
          child: SizedBox(
            height: 20,
            width: 20,
            child: Image.asset('assets/images/tick.png'),
          ),
        );
      }
    } else {
      return const SizedBox();
    }
  }
}
