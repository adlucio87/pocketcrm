import 'package:flutter/material.dart';
import 'package:pocketcrm/presentation/shared/dialog_helper.dart';

class SwipeToDeleteWrapper extends StatelessWidget {
  final Key itemKey;
  final Widget child;
  final VoidCallback onDelete;
  final String confirmTitle;
  final String confirmMessage;

  const SwipeToDeleteWrapper({
    super.key,
    required this.itemKey,
    required this.child,
    required this.onDelete,
    required this.confirmTitle,
    required this.confirmMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await DialogHelper.showDeleteConfirmDialog(
          context: context,
          title: confirmTitle,
          message: confirmMessage,
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: child,
    );
  }
}
