import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class ErrorAlert extends StatelessComponent {
  final String title;
  final String? description;

  ErrorAlert({super.key, required this.title, this.description});

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'border border-destructive/20 rounded-lg px-4 py-2 text-destructive',
      [
        div(classes: 'flex items-center', [
          i([], classes: 'icon-octagon-alert mr-2'),
          h4([Component.text(title)], classes: 'font-medium text-sm'),
        ]),
        if (description != null)
          section([Component.text(description!)], classes: 'mt-1 text-xs'),
      ],
    );
  }
}
