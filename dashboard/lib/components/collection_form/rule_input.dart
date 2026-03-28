import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../forms/components/form_field_builder.dart';
import '../../forms/reactive/reactive_forms.dart';

class RuleInput extends StatefulComponent {
  final String path;
  final String ruleLabel;
  final String description;
  final String icon;

  const RuleInput({
    super.key,
    required this.path,
    required this.ruleLabel,
    required this.description,
    required this.icon,
  });

  @override
  State<StatefulComponent> createState() => _RuleInputState();
}

class _RuleInputState extends State<RuleInput> {
  bool _focused = false;
  int _resetCounter = 0;

  @override
  Component build(BuildContext context) {
    final path = component.path;
    final icon = component.icon;
    final ruleLabel = component.ruleLabel;
    final description = component.description;

    return FormFieldBuilder<FormControl<String?>>(
      path: path,
      builder: (context, field) => div(classes: 'bg-card border border-border rounded-lg p-4', [
        div(classes: 'flex items-start gap-3', [
          div(classes: 'w-8 h-8 rounded-full bg-muted flex items-center justify-center shrink-0', [
            i(classes: '$icon text-muted-foreground text-sm', []),
          ]),
          div(classes: 'flex-1', [
            label(classes: 'label grid gap-2', [
              span(classes: 'text-sm font-medium text-foreground', [Component.text(ruleLabel)]),
              span(classes: 'text-xs text-muted-foreground', [Component.text(description)]),
              div(key: ValueKey('${path}_$_resetCounter'), classes: 'relative', [
                textarea(
                  [Component.text(field.value ?? '')],
                  name: 'rule${ruleLabel.replaceAll(' ', '')}',
                  classes: 'textarea font-mono text-sm pb-8',
                  rows: 2,
                  onInput: (v) => field.setValue(v),
                  events: {
                    'focusin': (_) => setState(() => _focused = true),
                    'focusout': (_) => setState(() => _focused = false),
                  },
                  attributes: {
                    'placeholder': field.value == null
                        ? 'Superusers only'
                        : field.value!.isEmpty && !_focused
                            ? 'Anyone'
                            : 'e.g. request.auth.id != null',
                  },
                ),
                if (field.value != null)
                  button(
                    classes:
                        'absolute bottom-1.5 left-1.5 px-2 py-1 text-[10px] font-medium text-muted-foreground hover:text-foreground hover:bg-muted/80 border border-transparent hover:border-border rounded transition-colors flex items-center gap-1',
                    events: events(onClick: () {
                      field.setValue(null);
                      setState(() => _resetCounter++);
                    }),
                    [i(classes: 'icon-lock text-[10px]', []), Component.text('Set Superusers only')],
                  ),
                if (field.value == null)
                  button(
                    classes:
                        'absolute bottom-1.5 left-1.5 px-2 py-1 text-[10px] font-medium text-muted-foreground hover:text-foreground hover:bg-muted/80 border border-transparent hover:border-border rounded transition-colors flex items-center gap-1',
                    events: events(onClick: () {
                      field.setValue('');
                      setState(() => _resetCounter++);
                    }),
                    [i(classes: 'icon-globe text-[10px]', []), Component.text('Set Public')],
                  ),
              ]),
            ]),
          ]),
        ]),
      ]),
    );
  }
}
