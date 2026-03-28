import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import 'progress_indicator.dart';

class RefreshIconButton extends StatefulComponent {
  final Future<void> Function() onClick;
  const RefreshIconButton({super.key, required this.onClick});

  @override
  State<StatefulComponent> createState() => _RefreshIconButtonState();
}

class _RefreshIconButtonState extends State<RefreshIconButton> {
  bool _refreshing = false;

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'btn-icon-outline',
      [
        if (_refreshing)
          const ProgressIndicator()
        else
          i([], classes: 'icon-rotate-ccw'),
      ],
      disabled: _refreshing,
      onClick: () async {
        try {
          setState(() => _refreshing = true);
          await Future.wait([
            component.onClick(),
            Future.delayed(Duration(milliseconds: 600)),
          ]);
        } finally {
          setState(() => _refreshing = false);
        }
      },
    );
  }
}
