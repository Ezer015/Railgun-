import 'package:flutter/material.dart';

import '../models.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({
    super.key,
    required this.userSummary,
  });

  final UserSummary userSummary;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: MemoryImage(userSummary.face),
            radius: 22.5,
          ),
          const SizedBox(width: 10),
          Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    userSummary.name,
                    style: TextStyle(
                      fontSize: 14,
                      // fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              if (userSummary.tag != null)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        userSummary.tag!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
}
