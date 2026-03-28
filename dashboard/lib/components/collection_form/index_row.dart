import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../forms/components/form_field_builder.dart';
import '../../forms/reactive/reactive_forms.dart';

/// Mobile-friendly card component for editing database indexes.
class IndexRow extends StatelessComponent {
  final int index;
  final List<String> availableColumns;
  final void Function()? onDelete;

  const IndexRow({
    super.key,
    required this.index,
    this.availableColumns = const [],
    this.onDelete,
  });

  String get _basePath => 'indexes.[$index]';

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'bg-card border border-border rounded-lg shadow-sm hover:shadow-md transition-shadow group',
      [
        _buildHeader(context),
        _buildBody(context),
      ],
    );
  }

  Component _buildHeader(BuildContext context) {
    return div(classes: 'flex items-center gap-3 p-3 border-b border-border', [
      div(classes: 'w-8 h-8 rounded-lg bg-purple-100 flex items-center justify-center shrink-0', [
        i(classes: 'icon-key text-purple-500 text-sm', []),
      ]),
      FormFieldBuilder<FormControl<String>>(
        path: '$_basePath.name',
        builder: (context, field) => div(classes: 'flex-1 min-w-0', [
          if (field.value.isNotEmpty)
            span(classes: 'font-medium text-foreground truncate block', [Component.text(field.value)])
          else
            span(classes: 'text-muted-foreground italic', [Component.text('New index')]),
        ]),
      ),
      // Badges
      div(classes: 'flex items-center gap-1 shrink-0', [
        FormFieldBuilder<FormControl<bool>>(
          path: '$_basePath.unique',
          builder: (context, field) => field.value
              ? span(classes: 'px-1.5 py-0.5 text-[10px] font-medium rounded bg-purple-100 text-purple-700', [
                  Component.text('UNIQUE'),
                ])
              : Component.fragment([]),
        ),
      ]),
      button(
        classes: 'btn-icon-ghost text-muted-foreground hover:text-destructive',
        events: events(onClick: onDelete),
        [i(classes: 'icon-trash text-sm', [])],
      ),
    ]);
  }

  Component _buildBody(BuildContext context) {
    return div(classes: 'p-3 space-y-3', [
      // Index name and columns - stack on mobile
      div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
        FormFieldBuilder<FormControl<String>>(
          path: '$_basePath.name',
          builder: (context, field) => label(classes: 'label grid gap-1', [
            span(classes: 'text-xs text-muted-foreground font-medium', [Component.text('Index Name')]),
            input(
              name: 'indexName_$index',
              classes: 'input text-sm',
              type: InputType.text,
              value: field.value,
              onInput: (value) => field.setValue(value),
              attributes: {'placeholder': 'e.g. idx_user_email'},
            ),
          ]),
        ),
        FormFieldBuilder<FormControl<String>>(
          path: '$_basePath.columns',
          builder: (context, field) => label(classes: 'label grid gap-1', [
            span(classes: 'text-xs text-muted-foreground font-medium', [Component.text('Columns (comma separated)')]),
            input(
              name: 'indexColumns_$index',
              classes: 'input text-sm font-mono',
              type: InputType.text,
              value: field.value,
              onInput: (value) => field.setValue(value),
              attributes: {'placeholder': 'e.g. user_id, created_at'},
            ),
          ]),
        ),
      ]),

      // Options row
      div(classes: 'flex flex-wrap items-center gap-4 pt-2 border-t border-border', [
        FormFieldBuilder<FormControl<bool>>(
          path: '$_basePath.unique',
          builder: (context, field) => label(classes: 'flex items-center gap-2 text-sm cursor-pointer', [
            input(
              name: 'indexUnique_$index',
              type: InputType.checkbox,
              classes: 'checkbox',
              checked: field.value,
              onChange: (v) {
                if (v is bool) field.setValue(v);
              },
            ),
            span(classes: 'text-muted-foreground', [Component.text('Unique')]),
          ]),
        ),
        FormFieldBuilder<FormControl<bool>>(
          path: '$_basePath.if_not_exists',
          builder: (context, field) => label(classes: 'flex items-center gap-2 text-sm cursor-pointer', [
            input(
              name: 'indexIfNotExists_$index',
              type: InputType.checkbox,
              classes: 'checkbox',
              checked: field.value,
              onChange: (v) {
                if (v is bool) field.setValue(v);
              },
            ),
            span(classes: 'text-muted-foreground', [Component.text('If Not Exists')]),
          ]),
        ),
      ]),
    ]);
  }
}
