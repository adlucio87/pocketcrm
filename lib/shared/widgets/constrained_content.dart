import 'package:flutter/material.dart';
import 'package:pocketcrm/core/utils/responsive.dart';

/// Wraps [child] in a centered [ConstrainedBox] that caps width
/// at [maxWidth] (defaults to [Responsive.contentMaxWidth]).
///
/// On phones the constraint is effectively infinite, so layouts
/// are unchanged. On tablets the content is horizontally centered
/// with comfortable reading width.
class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ConstrainedContent({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}
