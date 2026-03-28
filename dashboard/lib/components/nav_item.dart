import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_router/jaspr_router.dart';

class NavItem extends StatelessComponent {
  final String label;
  final String icon;
  final bool active;
  final String? trailing;
  final String to;
  final bool expanded;
  final VoidCallback? onTap;

  const NavItem({
    super.key,
    required this.label,
    required this.icon,
    this.active = false,
    this.trailing,
    required this.to,
    this.expanded = false,
    this.onTap,
  });

  @override
  Component build(BuildContext context) {
    final baseClasses =
        'flex items-center justify-between px-3 py-2 rounded-md text-sm font-medium transition-all duration-200';
    final textClasses = active
        ? 'bg-primary/8 text-foreground border-l-2 border-primary'
        : 'text-muted-foreground hover:text-foreground hover:bg-accent border-l-2 border-transparent';

    return div(
      events: onTap != null ? events(onClick: onTap) : null,
      [
        Link(
          to: to,
          classes: '$baseClasses $textClasses',
          child: div(classes: 'flex space-x-2 select-none', [
            i([], classes: 'icon-$icon w-4 h-4 mr-1'),
            span(
              classes:
                  // Always show label on mobile, respect expanded on desktop
                  'whitespace-nowrap transition-opacity ${expanded ? '' : 'md:opacity-0 md:pointer-events-none'}',
              [Component.text(label)],
            ),
          ]),
        ),
      ],
    );
  }
}
