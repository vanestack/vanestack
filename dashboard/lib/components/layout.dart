import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../providers/collections.dart';
import '../providers/user.dart';
import 'nav_item.dart';

class Layout extends StatefulComponent {
  final Component child;
  final String? path;

  const Layout({super.key, required this.child, this.path = ''});

  @override
  State<StatefulComponent> createState() => LayoutState();

  static LayoutState of(BuildContext context) {
    final state = context.findAncestorStateOfType<LayoutState>();
    if (state == null) {
      throw Exception('No LayoutState found in context');
    }
    return state;
  }
}

class LayoutState extends State<Layout> {
  bool mobileMenuOpen = false;

  void toggleMobileMenu() {
    setState(() {
      mobileMenuOpen = !mobileMenuOpen;
    });
  }

  @override
  Component build(BuildContext context) {
    final user = context.watch(userProvider);
    final expanded = switch (component.path) {
      String v when v.startsWith('/_/collections/') => false,
      String v when v.startsWith('/_/storage/') => false,
      _ => true,
    };

    final collections = context.watch(collectionsProvider).value;

    return div(classes: 'flex min-h-screen bg-muted overflow-hidden', [
      // Mobile menu backdrop
      div(
        classes:
            'fixed inset-0 bg-black/50 z-40 transition-opacity duration-300 md:hidden ${mobileMenuOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'}',
        events: events(onClick: () => setState(() => mobileMenuOpen = false)),
        [],
      ),
      // Sidebar navigation
      nav(
        classes:
            'transition-all duration-300 overflow-hidden bg-card border-r border-border flex flex-col justify-between '
            // Mobile: fixed overlay, hidden by default
            'fixed md:relative inset-y-0 left-0 z-50 w-64 '
            '${mobileMenuOpen ? 'translate-x-0' : '-translate-x-full'} '
            // Desktop: normal sidebar behavior
            'md:translate-x-0 ${expanded ? 'md:w-64' : 'md:w-18'}',
        [
          div(classes: 'p-4 space-y-6 overflow-y-auto overflow-x-hidden', [
            div(classes: 'flex items-center justify-between', [
              div(classes: 'flex items-center space-x-2', [
                img(
                  src: '/_/images/logo.png',
                  alt: 'Logo',
                  classes: 'w-8',
                ),
                span(
                  classes:
                      'font-display font-bold text-lg text-foreground transition-all duration-500 transform ${expanded ? 'md:opacity-100 md:pointer-events-auto' : 'md:opacity-0 md:pointer-events-none'}',
                  [Component.text('VaneStack')],
                ),
              ]),
              // Close button for mobile
              button(
                classes: 'md:hidden p-2 rounded-md hover:bg-accent',
                events: events(onClick: () => setState(() => mobileMenuOpen = false)),
                [i(classes: 'icon-x text-muted-foreground', [])],
              ),
            ]),
            div(classes: 'space-y-2', [
              NavItem(
                expanded: expanded,
                label: 'Home',
                icon: 'house',
                active: component.path?.startsWith('/_/home') ?? false,
                to: '/_/home',
                onTap: () => setState(() => mobileMenuOpen = false),
              ),
              NavItem(
                expanded: expanded,
                label: 'Collections',
                icon: 'database',
                active: component.path?.startsWith('/_/collections') ?? false,
                to: '/_/collections${collections?.isNotEmpty == true ? '/${collections!.first.name}' : ''}',
                onTap: () => setState(() => mobileMenuOpen = false),
              ),
              NavItem(
                expanded: expanded,
                label: 'Users',
                icon: 'users-round',
                active: component.path?.startsWith('/_/users') ?? false,
                to: '/_/users',
                onTap: () => setState(() => mobileMenuOpen = false),
              ),
              NavItem(
                expanded: expanded,
                label: 'Storage',
                icon: 'box',
                active: component.path?.startsWith('/_/storage') ?? false,
                to: '/_/storage',
                onTap: () => setState(() => mobileMenuOpen = false),
              ),
              NavItem(
                expanded: expanded,
                label: 'Logs',
                icon: 'logs',
                active: component.path?.startsWith('/_/logs') ?? false,
                to: '/_/logs',
                onTap: () => setState(() => mobileMenuOpen = false),
              ),
              NavItem(
                expanded: expanded,
                label: 'Settings',
                icon: 'settings',
                active: component.path?.startsWith('/_/settings') ?? false,
                to: '/_/settings',
                onTap: () => setState(() => mobileMenuOpen = false),
              ),
            ]),
          ]),
          Link(
            to: '/_/profile',
            classes:
                'p-4 border-t border-border flex items-center justify-between hover:bg-muted transition-colors',
            child: div(classes: 'flex items-center justify-between w-full', [
              div(classes: 'flex items-center space-x-3', [
                div(
                  classes:
                      'w-9 h-9 rounded-full flex items-center justify-center bg-gradient-to-br from-blue-500 to-indigo-600',
                  [i([], classes: 'icon-user text-white text-sm')],
                ),
                div(classes: expanded ? '' : 'md:opacity-0 md:pointer-events-none', [
                  span(classes: 'text-sm font-medium text-foreground', [
                    Component.text(user.value?.name ?? 'Admin'),
                  ]),
                  br(),
                  span(classes: 'text-xs text-muted-foreground', [
                    Component.text(user.value?.email ?? ''),
                  ]),
                ]),
              ]),
              i([], classes: 'icon-chevron-right text-muted-foreground'),
            ]),
          ),
        ],
      ),
      // Main content area
      div(key: ValueKey(component.path), classes: 'flex-1 overflow-y-auto h-screen bg-card flex flex-col', [
        component.child,
      ]),
    ]);
  }
}
