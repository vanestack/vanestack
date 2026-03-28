import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class SortIcon extends StatelessComponent {
  final bool show;
  final SortDirection direction;

  const SortIcon({super.key, required this.show, required this.direction});

  @override
  Component build(BuildContext context) {
    if (!show) return Component.empty();
    return i(
      classes:
          "icon-arrow-down-wide-narrow ml-auto transition-transform ${direction == SortDirection.desc ? 'rotate-180' : ''}",
      [],
    );
  }
}
