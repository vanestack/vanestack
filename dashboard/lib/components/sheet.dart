import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Sheet extends StatefulComponent {
  final bool isOpen;
  final VoidCallback onClose;
  final Component child;

  Sheet({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.child,
  });

  @override
  State<StatefulComponent> createState() => SheetState();

  static SheetState? of(BuildContext context) {
    return context.findAncestorStateOfType<SheetState>();
  }
}

class SheetState extends State<Sheet> {
  void close() {
    component.onClose();
  }

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      div(
        classes:
            'fixed inset-0 bg-black/20 backdrop-blur-xs z-60 transition-opacity duration-300 backdrop-${component.isOpen ? 'visible' : 'hidden'}',
        events: events(onClick: close),
        [],
      ),
      div(
        classes:
            'fixed top-0 right-0 h-full w-full max-w-2xl bg-card shadow-2xl z-70 transition-transform duration-300 ease-in-out sheet-${component.isOpen ? 'open' : 'closed'} flex flex-col',
        [component.child],
      ),
    ]);
  }
}
