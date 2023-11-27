import 'package:flutter/material.dart';
import '/forum/models/comment.dart';
import '/forum/palette.dart';
import '/forum/services/local_services.dart';
import '/forum/views/user_page.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({
    Key? key,
    required this.comment,
  }) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    String date = LocalServices().getFormatedDate(comment.date);
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 224, 224, 224),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_circle,
                size: 15,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPage(
                        userId: comment.userId,
                      ),
                    ),
                  );
                },
                child: Text(
                  comment.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                size: 15,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
