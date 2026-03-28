import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:uuid/uuid.dart';

class Popover extends StatefulComponent {
  final Component child;
  final List<Component> children;
  final String? side;
  final String? align;

  Popover({super.key, required this.child, this.children = const [], this.side, this.align});

  @override
  State<Popover> createState() => PopoverState();
}

class PopoverState extends State<Popover> {
  final _id = const Uuid().v7();

  @override
  Component build(BuildContext context) {
    return div(id: _id, classes: 'popover', [
      Component.wrapElement(
        child: component.child,
        id: '${_id}_trigger',
        classes: 'cursor-pointer',
        attributes: {
          'aria-expanded': 'false',
          'aria-controls': '${_id}_popover',
        },
      ),
      div(
        id: '${_id}_popover',
        classes: 'w-40 p-1',
        attributes: {
          'data-popover': '',
          if (component.side != null) 'data-side': component.side!,
          if (component.align != null) 'data-align': component.align!,
          'aria-hidden': 'true',
        },
        [
          div(component.children),
        ],
      ),
    ]);
  }
}
