import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import 'layout.dart';

class MenuButton extends StatelessComponent {
  final String? classes;
  const MenuButton({
    this.classes,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return Component.wrapElement(
      classes: classes,
      child: button(
        classes: 'btn-icon-ghost',
        [
          i([], classes: 'icon-menu stroke-3'),
        ],

        onClick: () => Layout.of(context).toggleMobileMenu(),
      ),
    );
  }
}
