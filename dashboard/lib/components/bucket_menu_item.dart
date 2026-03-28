import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class BucketMenuItem extends StatelessComponent {
  final String label;
  final String icon;
  final bool active;
  final String? trailing;
  final String to;

  const BucketMenuItem({
    super.key,
    required this.label,
    required this.icon,
    this.active = false,
    this.trailing,
    required this.to,
  });

  @override
  Component build(BuildContext context) {
    final baseClasses = 'flex items-center justify-between px-3 py-2 rounded-md text-sm font-medium transition-colors';
    final textClasses = active ? 'bg-muted text-foreground' : 'text-muted-foreground hover:text-foreground hover:bg-accent';

    return Link(
      to: to,
      classes: '$baseClasses $textClasses',
      child: div(classes: 'flex space-x-2 select-none', [
        i([], classes: 'icon-$icon w-4 h-4 mr-1'),
        span(classes: 'whitespace-nowrap', [Component.text(label)]),
      ]),
    );
  }
}
