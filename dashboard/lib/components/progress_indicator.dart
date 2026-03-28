import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class ProgressIndicator extends StatelessComponent {
  const ProgressIndicator({super.key});
  @override
  Component build(BuildContext context) {
    return svg(
      classes: 'animate-spin',
      width: 24.px,
      height: 24.px,
      viewBox: '0 0 24 24',
      attributes: {
        "xmlns": 'http://www.w3.org/2000/svg',
        "fill": "none",
        "stroke": "currentColor",
        "stroke-width": "2",
        "stroke-linecap": "round",
        "stroke-linejoin": "round",
      },
      [
        path([], d: 'M12 2v4'),
        path([], d: 'm16.2 7.8 2.9-2.9'),
        path([], d: 'M18 12h4'),
        path([], d: 'm16.2 16.2 2.9 2.9'),
        path([], d: 'M12 18v4'),
        path([], d: 'm4.9 19.1 2.9-2.9'),
        path([], d: 'M2 12h4'),
        path([], d: 'm4.9 4.9 2.9 2.9'),
      ],
    );
  }
}
