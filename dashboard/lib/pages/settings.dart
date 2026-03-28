import 'package:vanestack_dashboard/components/menu_button.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_router/jaspr_router.dart';

class SettingsPage extends StatefulComponent {
  final Component child;
  final String? path;
  const SettingsPage({super.key, required this.child, this.path});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isMenuOpen = false;

  String _getCurrentPageLabel() {
    switch (component.path) {
      case '/_/settings/application':
        return 'Application';
      case '/_/settings/auth':
        return 'Auth';
      case '/_/settings/storage':
        return 'Storage';
      case '/_/settings/email':
        return 'Email';
      case '/_/settings/superusers':
        return 'Superusers';
      default:
        return 'Settings';
    }
  }

  String _getCurrentPageIcon() {
    switch (component.path) {
      case '/_/settings/application':
        return 'app-window';
      case '/_/settings/auth':
        return 'user';
      case '/_/settings/storage':
        return 'archive';
      case '/_/settings/email':
        return 'mail';
      case '/_/settings/superusers':
        return 'shield';
      default:
        return 'settings';
    }
  }

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'flex flex-col flex-1 h-full overflow-hidden',
      [
        div(
          classes: 'h-16 bg-card md:border-b border-border shrink-0 px-4 flex items-center justify-between',
          [
            div(classes: 'flex', [
              MenuButton(
                classes: 'md:hidden mr-2',
              ),
              div([
                h1(
                  classes: 'text-2xl font-semibold',
                  [Component.text('Settings')],
                ),
              ]),
            ]),
          ],
        ),
        div(classes: "flex-1 h-full overflow-x-auto flex flex-col md:flex-row", [
          // Mobile dropdown - shown only on mobile
          div(classes: 'md:hidden px-4 pt-2 pb-4 bg-card border-b border-border', [
            div(classes: 'popover w-full', [
              button(
                classes: 'btn-secondary w-full justify-between',
                onClick: () => setState(() => _isMenuOpen = !_isMenuOpen),
                [
                  span(classes: 'flex items-center gap-2', [
                    i(classes: 'icon-${_getCurrentPageIcon()}', []),
                    Component.text(_getCurrentPageLabel()),
                  ]),
                  i(classes: 'icon-chevron-down', []),
                ],
              ),
              section(
                attributes: {
                  'data-popover': '',
                  'data-side': 'bottom',
                  'data-align': 'start',
                  'aria-hidden': (!_isMenuOpen).toString(),
                },
                classes: 'p-2 flex flex-col gap-1 w-full',
                [
                  _MobileSettingsMenuItem(
                    label: 'Application',
                    icon: 'app-window',
                    active: component.path == '/_/settings/application',
                    to: '/_/settings/application',
                    onTap: () => setState(() => _isMenuOpen = false),
                  ),
                  _MobileSettingsMenuItem(
                    label: 'Auth',
                    icon: 'user',
                    active: component.path == '/_/settings/auth',
                    to: '/_/settings/auth',
                    onTap: () => setState(() => _isMenuOpen = false),
                  ),
                  _MobileSettingsMenuItem(
                    label: 'Storage',
                    icon: 'archive',
                    active: component.path == '/_/settings/storage',
                    to: '/_/settings/storage',
                    onTap: () => setState(() => _isMenuOpen = false),
                  ),
                  _MobileSettingsMenuItem(
                    label: 'Email',
                    icon: 'mail',
                    active: component.path == '/_/settings/email',
                    to: '/_/settings/email',
                    onTap: () => setState(() => _isMenuOpen = false),
                  ),
                  _MobileSettingsMenuItem(
                    label: 'Superusers',
                    icon: 'shield',
                    active: component.path == '/_/settings/superusers',
                    to: '/_/settings/superusers',
                    onTap: () => setState(() => _isMenuOpen = false),
                  ),
                ],
              ),
            ]),
          ]),
          // Desktop nav - hidden on mobile
          nav(classes: 'hidden md:block w-48 shrink-0 p-4 mr-4 bg-card border-r border-border', [
            ul(classes: 'space-y-1', [
              li([
                SettingsMenuItem(
                  label: 'Application',
                  icon: 'app-window',
                  active: component.path == '/_/settings/application',
                  to: '/_/settings/application',
                ),
              ]),
              li([
                SettingsMenuItem(
                  label: 'Auth',
                  icon: 'user',
                  active: component.path == '/_/settings/auth',
                  to: '/_/settings/auth',
                ),
              ]),
              li([
                SettingsMenuItem(
                  label: 'Storage',
                  icon: 'archive',
                  active: component.path == '/_/settings/storage',
                  to: '/_/settings/storage',
                ),
              ]),
              li([
                SettingsMenuItem(
                  label: 'Email',
                  icon: 'mail',
                  active: component.path == '/_/settings/email',
                  to: '/_/settings/email',
                ),
              ]),
              li([
                SettingsMenuItem(
                  label: 'Superusers',
                  icon: 'shield',
                  active: component.path == '/_/settings/superusers',
                  to: '/_/settings/superusers',
                ),
              ]),
            ]),
          ]),
          div(classes: 'w-full md:w-3/4 lg:w-4/5 p-4', [
            div(classes: 'max-w-2xl', [component.child]),
          ]),
        ]),
      ],
    );
  }
}

class SettingsMenuItem extends StatelessComponent {
  final String label;
  final String icon;
  final bool active;
  final String? trailing;
  final String to;

  const SettingsMenuItem({
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

class _MobileSettingsMenuItem extends StatelessComponent {
  final String label;
  final String icon;
  final bool active;
  final String to;
  final VoidCallback onTap;

  const _MobileSettingsMenuItem({
    required this.label,
    required this.icon,
    this.active = false,
    required this.to,
    required this.onTap,
  });

  @override
  Component build(BuildContext context) {
    final baseClasses = 'flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium transition-colors w-full';
    final textClasses = active ? 'bg-muted text-foreground' : 'text-muted-foreground hover:text-foreground hover:bg-accent';

    return div(
      events: events(onClick: onTap),
      [
        Link(
          to: to,
          classes: '$baseClasses $textClasses',
          child: div(classes: 'flex items-center gap-2 select-none', [
            i([], classes: 'icon-$icon w-4 h-4'),
            span(classes: 'whitespace-nowrap', [Component.text(label)]),
          ]),
        ),
      ],
    );
  }
}
