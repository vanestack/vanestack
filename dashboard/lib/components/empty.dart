import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class Empty extends StatelessComponent {
  final String title;
  final String description;
  final Component? button;
  final String icon;
  const Empty({
    super.key,
    required this.title,
    required this.description,
    this.button,
    required this.icon,
  });

  @override
  Component build(BuildContext context) {
    return div(
      [
        header(classes: 'flex max-w-sm flex-col items-center gap-2 text-center', [
          div(
            classes:
                "mb-2 border border-muted bg-card text-foreground flex size-10 shrink-0 items-center justify-center rounded-lg",
            [i(classes: 'icon-$icon', [])],
          ),
          h3(classes: "text-lg font-medium tracking-tight", [Component.text(title)]),
          p(
            classes:
                "text-muted-foreground [&>a:hover]:text-primary text-sm/relaxed [&>a]:underline [&>a]:underline-offset-",
            [Component.text(description)],
          ),
        ]),
        if (button != null)
          section(
            classes:
                'flex w-full max-w-sm min-w-0 flex-col items-center gap-4 text-sm text-balance',
            [
              div(classes: 'flex gap-2', [button!]),
            ],
          ),
      ],
      classes:
          'flex min-w-0 flex-1 flex-col items-center justify-center gap-4 rounded-lg border-dashed p-6 text-center text-balance md:p-12 text-foreground',
    );
  }
}
