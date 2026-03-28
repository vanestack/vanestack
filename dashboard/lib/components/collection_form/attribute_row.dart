import 'package:vanestack_common/vanestack_common.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../forms/components/form_field_builder.dart';
import '../../forms/components/form_scope.dart';
import '../../forms/reactive/reactive_forms.dart';

/// Card-based, mobile-friendly attribute row component for editing collection columns.
class AttributeRow extends StatelessComponent {
  final int index;
  final bool isSystem;
  final bool isDragOver;
  final bool isExpanded;
  final List<Collection> allCollections;
  final void Function()? onDelete;
  final void Function()? onToggleExpanded;
  final void Function()? onDragStart;
  final void Function()? onDragOver;
  final void Function()? onDragEnd;

  const AttributeRow({
    super.key,
    required this.index,
    this.isSystem = false,
    this.isDragOver = false,
    this.isExpanded = false,
    this.allCollections = const [],
    this.onDelete,
    this.onToggleExpanded,
    this.onDragStart,
    this.onDragOver,
    this.onDragEnd,
  });

  String get _basePath => 'attributes.[$index]';

  String _typeIcon(String type, bool primaryKey) => switch (type) {
        _ when primaryKey => 'icon-key',
        'TEXT' => 'icon-type',
        'INTEGER' || 'REAL' => 'icon-hash',
        'BOOL' => 'icon-toggle-left',
        'DATE' => 'icon-calendar',
        'JSON' => 'icon-braces',
        _ => 'icon-type',
      };

  String _typeBgColor(String type, bool primaryKey) => switch (type) {
        _ when primaryKey => 'bg-warning/10',
        'TEXT' => 'bg-primary/10',
        'INTEGER' || 'REAL' => 'bg-success/10',
        'BOOL' => 'bg-purple-100',
        'DATE' => 'bg-orange-100',
        'JSON' => 'bg-pink-100',
        _ => 'bg-primary/10',
      };

  String _typeTextColor(String type, bool primaryKey) => switch (type) {
        _ when primaryKey => 'text-warning',
        'TEXT' => 'text-primary',
        'INTEGER' || 'REAL' => 'text-success',
        'BOOL' => 'text-purple-600',
        'DATE' => 'text-orange-600',
        'JSON' => 'text-pink-600',
        _ => 'text-primary',
      };

  @override
  Component build(BuildContext context) {
    final form = FormScope.of(context);
    final group = form.getGroup(_basePath);
    if (group == null) return div([]);

    final type = group.getControl<String>('type')?.value ?? 'TEXT';
    final primaryKey = group.getControl<bool>('primary_key')?.value ?? false;

    return div(
      attributes: {'draggable': isSystem ? 'false' : 'true'},
      events: isSystem
          ? {}
          : {
              'dragstart': (e) => onDragStart?.call(),
              'dragover': (e) {
                e.preventDefault();
                onDragOver?.call();
              },
              'dragend': (e) => onDragEnd?.call(),
            },
      classes:
          'bg-card border rounded-lg shadow-sm hover:shadow-md transition-shadow ${isDragOver ? 'ring-2 ring-primary' : 'border-border'} ${isSystem ? 'opacity-70' : ''}',
      [
        _buildHeader(context, type, primaryKey),
        _buildBody(context),
        if (isExpanded && !isSystem) _buildAdvancedPanel(context),
      ],
    );
  }

  Component _buildHeader(BuildContext context, String type, bool primaryKey) {
    return div(classes: 'flex items-center gap-3 p-3 border-b border-border', [
      // Drag handle
      if (!isSystem)
        div(
          classes: 'cursor-grab text-muted-foreground hover:text-foreground hidden sm:block',
          [i(classes: 'icon-grip-vertical', [])],
        ),

      // Type icon badge
      div(classes: 'w-8 h-8 rounded-lg ${_typeBgColor(type, primaryKey)} flex items-center justify-center shrink-0', [
        i(classes: '${_typeIcon(type, primaryKey)} ${_typeTextColor(type, primaryKey)} text-sm', []),
      ]),

      // Column name (prominent)
      FormFieldBuilder<FormControl<String>>(
        path: '$_basePath.name',
        builder: (context, field) => div(classes: 'flex-1 min-w-0', [
          if (field.value.isNotEmpty)
            span(classes: 'font-medium text-foreground truncate block', [Component.text(field.value)])
          else
            span(classes: 'text-muted-foreground italic', [Component.text('New column')]),
        ]),
      ),

      // Constraint badges
      _buildConstraintBadges(context),

      // Delete button
      if (!isSystem)
        button(
          classes: 'btn-icon-ghost text-muted-foreground hover:text-destructive',
          events: events(onClick: onDelete),
          [i(classes: 'icon-trash text-sm', [])],
        ),
    ]);
  }

  Component _buildConstraintBadges(BuildContext context) {
    return div(classes: 'flex items-center gap-1 shrink-0', [
      FormFieldBuilder<FormControl<bool>>(
        path: '$_basePath.primary_key',
        builder: (context, field) => field.value
            ? span(classes: 'px-1.5 py-0.5 text-[10px] font-medium rounded bg-warning/10 text-warning', [
                Component.text('PK'),
              ])
            : Component.fragment([]),
      ),
      FormFieldBuilder<FormControl<bool>>(
        path: '$_basePath.unique',
        builder: (context, field) {
          final form = FormScope.of(context);
          final primaryKey = form.getControl<bool>('$_basePath.primary_key')?.value ?? false;
          return (field.value && !primaryKey)
              ? span(classes: 'px-1.5 py-0.5 text-[10px] font-medium rounded bg-primary/10 text-primary', [
                  Component.text('UQ'),
                ])
              : Component.fragment([]);
        },
      ),
      FormFieldBuilder<FormControl<bool>>(
        path: '$_basePath.nullable',
        builder: (context, field) => !field.value
            ? span(classes: 'px-1.5 py-0.5 text-[10px] font-medium rounded bg-destructive/20 text-destructive', [
                Component.text('REQ'),
              ])
            : Component.fragment([]),
      ),
      FormFieldBuilder<FormControl<String>>(
        path: '$_basePath.foreign_key_table',
        builder: (context, field) => field.value.isNotEmpty
            ? span(classes: 'px-1.5 py-0.5 text-[10px] font-medium rounded bg-purple-100 text-purple-700', [
                Component.text('FK'),
              ])
            : Component.fragment([]),
      ),
    ]);
  }

  Component _buildBody(BuildContext context) {
    return div(classes: 'p-3 space-y-3', [
      // Row 1: Type and Name
      div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
        FormFieldBuilder<FormControl<String>>(
          path: '$_basePath.type',
          builder: (context, field) => label(classes: 'label grid gap-1', [
            span(classes: 'text-xs text-muted-foreground font-medium', [Component.text('Type')]),
            select(
              name: 'attributeType_$index',
              disabled: isSystem,
              classes: 'select text-sm',
              value: field.value,
              [
                option([], selected: field.value == 'TEXT', value: 'TEXT', label: 'Text'),
                option([], selected: field.value == 'INTEGER', value: 'INTEGER', label: 'Integer'),
                option([], selected: field.value == 'REAL', value: 'REAL', label: 'Real'),
                option([], selected: field.value == 'BOOL', value: 'BOOL', label: 'Bool'),
                option([], selected: field.value == 'DATE', value: 'DATE', label: 'Date'),
                option([], selected: field.value == 'JSON', value: 'JSON', label: 'Json'),
              ],
              onInput: (selected) => field.setValue(selected.first),
            ),
          ]),
        ),
        FormFieldBuilder<FormControl<String>>(
          path: '$_basePath.name',
          builder: (context, field) => label(classes: 'label grid gap-1', [
            span(classes: 'text-xs text-muted-foreground font-medium', [Component.text('Column Name')]),
            input(
              name: 'attributeName_$index',
              classes: 'input text-sm',
              type: InputType.text,
              disabled: isSystem,
              value: field.value,
              onInput: (value) => field.setValue(value),
              attributes: {'placeholder': 'e.g. user_id'},
            ),
          ]),
        ),
      ]),

      // Row 2: Default value
      FormFieldBuilder<FormControl<String>>(
        path: '$_basePath.default_value',
        builder: (context, field) => label(classes: 'label grid gap-1', [
          span(classes: 'text-xs text-muted-foreground font-medium', [Component.text('Default Value')]),
          input(
            name: 'attributeDefault_$index',
            classes: 'input text-sm font-mono',
            type: InputType.text,
            disabled: isSystem,
            value: field.value,
            onInput: (value) => field.setValue(value),
            attributes: {'placeholder': 'e.g. (unixepoch()) or literal value'},
          ),
        ]),
      ),

      // Row 3: Options toggles
      if (!isSystem) _buildOptionsRow(context),
    ]);
  }

  Component _buildOptionsRow(BuildContext context) {
    final form = FormScope.of(context);
    final hasForeignKey = (form.getControl<String>('$_basePath.foreign_key_table')?.value ?? '').isNotEmpty;
    final hasCheckConstraint = (form.getControl<String>('$_basePath.check_constraint')?.value ?? '').isNotEmpty;

    return div(classes: 'flex flex-wrap items-center gap-4 pt-2 border-t border-border', [
      FormFieldBuilder<FormControl<bool>>(
        path: '$_basePath.primary_key',
        builder: (context, field) => label(classes: 'flex items-center gap-2 text-sm cursor-pointer', [
          input(
            name: 'pk_$index',
            type: InputType.checkbox,
            classes: 'input',
            checked: field.value,
            onChange: (v) {
              if (v is bool) field.setValue(v);
            },
          ),
          span(classes: 'text-muted-foreground', [Component.text('Primary Key')]),
        ]),
      ),
      FormFieldBuilder<FormControl<bool>>(
        path: '$_basePath.unique',
        builder: (context, field) => label(classes: 'flex items-center gap-2 text-sm cursor-pointer', [
          input(
            name: 'unique_$index',
            type: InputType.checkbox,
            classes: 'input',
            checked: field.value,
            onChange: (v) {
              if (v is bool) field.setValue(v);
            },
          ),
          span(classes: 'text-muted-foreground', [Component.text('Unique')]),
        ]),
      ),
      FormFieldBuilder<FormControl<bool>>(
        path: '$_basePath.nullable',
        builder: (context, field) => label(classes: 'flex items-center gap-2 text-sm cursor-pointer', [
          input(
            name: 'nullable_$index',
            type: InputType.checkbox,
            classes: 'input',
            checked: field.value,
            onChange: (v) {
              if (v is bool) field.setValue(v);
            },
          ),
          span(classes: 'text-muted-foreground', [Component.text('Nullable')]),
        ]),
      ),
      button(
        classes:
            'ml-auto text-sm ${isExpanded ? 'text-purple-600' : 'text-muted-foreground'} hover:text-purple-600 flex items-center gap-1',
        events: events(onClick: onToggleExpanded),
        [
          i(classes: 'icon-settings text-xs', []),
          Component.text(isExpanded ? 'Hide Advanced' : 'Advanced'),
          if (hasForeignKey || hasCheckConstraint) span(classes: 'w-2 h-2 bg-purple-500 rounded-full', []),
        ],
      ),
    ]);
  }

  Component _buildAdvancedPanel(BuildContext context) {
    return div(classes: 'p-3 bg-muted border-t border-border space-y-4', [
      // Foreign Key section
      _buildForeignKeySection(context),
      // Check constraint section
      _buildCheckConstraintSection(context),
    ]);
  }

  Component _buildForeignKeySection(BuildContext context) {
    return div([
      div(classes: 'flex items-center gap-2 mb-2', [
        i(classes: 'icon-link text-purple-500', []),
        span(classes: 'text-sm font-medium text-foreground', [Component.text('Foreign Key')]),
      ]),
      div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-3', [
        FormFieldBuilder<FormControl<String>>(
          path: '$_basePath.foreign_key_table',
          builder: (context, field) => label(classes: 'label grid gap-1', [
            span(classes: 'text-xs text-muted-foreground', [Component.text('Reference Table')]),
            select(
              name: 'fk_table_$index',
              classes: 'select text-sm',
              value: field.value,
              [
                option([], value: '', label: 'None'),
                for (final col in allCollections)
                  option([], selected: field.value == col.name, value: col.name, label: col.name),
              ],
              onInput: (selected) {
                final value = selected.first;
                field.setValue(value);
                // Reset column to 'id' when table changes
                if (value.isNotEmpty) {
                  final form = FormScope.of(context);
                  final colField = form.getControl<String>('$_basePath.foreign_key_column');
                  if (colField != null && colField.value.isEmpty) {
                    colField.setValue('id');
                  }
                }
              },
            ),
          ]),
        ),
        FormFieldBuilder<FormControl<String>>(
          path: '$_basePath.foreign_key_column',
          builder: (context, field) {
            final form = FormScope.of(context);
            final tableValue = form.getControl<String>('$_basePath.foreign_key_table')?.value ?? '';
            return label(classes: 'label grid gap-1', [
              span(classes: 'text-xs text-muted-foreground', [Component.text('Reference Column')]),
              input(
                name: 'fk_column_$index',
                classes: 'input text-sm',
                type: InputType.text,
                value: field.value.isEmpty ? 'id' : field.value,
                disabled: tableValue.isEmpty,
                onInput: (value) => field.setValue(value),
              ),
            ]);
          },
        ),
        FormFieldBuilder<FormControl<String>>(
          path: '$_basePath.foreign_key_on_delete',
          builder: (context, field) {
            final form = FormScope.of(context);
            final tableValue = form.getControl<String>('$_basePath.foreign_key_table')?.value ?? '';
            return label(classes: 'label grid gap-1', [
              span(classes: 'text-xs text-muted-foreground', [Component.text('On Delete')]),
              select(
                name: 'fk_ondelete_$index',
                classes: 'select text-sm',
                disabled: tableValue.isEmpty,
                value: field.value,
                [
                  option([], value: '', label: 'No Action'),
                  option([], selected: field.value == 'CASCADE', value: 'CASCADE', label: 'Cascade'),
                  option([], selected: field.value == 'SET NULL', value: 'SET NULL', label: 'Set Null'),
                  option([], selected: field.value == 'RESTRICT', value: 'RESTRICT', label: 'Restrict'),
                ],
                onInput: (selected) => field.setValue(selected.first),
              ),
            ]);
          },
        ),
        FormFieldBuilder<FormControl<String>>(
          path: '$_basePath.foreign_key_on_update',
          builder: (context, field) {
            final form = FormScope.of(context);
            final tableValue = form.getControl<String>('$_basePath.foreign_key_table')?.value ?? '';
            return label(classes: 'label grid gap-1', [
              span(classes: 'text-xs text-muted-foreground', [Component.text('On Update')]),
              select(
                name: 'fk_onupdate_$index',
                classes: 'select text-sm',
                disabled: tableValue.isEmpty,
                value: field.value,
                [
                  option([], value: '', label: 'No Action'),
                  option([], selected: field.value == 'CASCADE', value: 'CASCADE', label: 'Cascade'),
                  option([], selected: field.value == 'SET NULL', value: 'SET NULL', label: 'Set Null'),
                  option([], selected: field.value == 'RESTRICT', value: 'RESTRICT', label: 'Restrict'),
                ],
                onInput: (selected) => field.setValue(selected.first),
              ),
            ]);
          },
        ),
      ]),
    ]);
  }

  Component _buildCheckConstraintSection(BuildContext context) {
    return div([
      div(classes: 'flex items-center gap-2 mb-2', [
        i(classes: 'icon-check-circle text-success', []),
        span(classes: 'text-sm font-medium text-foreground', [Component.text('Check Constraint')]),
      ]),
      FormFieldBuilder<FormControl<String>>(
        path: '$_basePath.check_constraint',
        builder: (context, field) => input(
          name: 'check_$index',
          classes: 'input text-sm font-mono',
          type: InputType.text,
          value: field.value,
          onInput: (value) => field.setValue(value),
          attributes: {'placeholder': 'e.g. length(name) > 0 AND length(name) < 100'},
        ),
      ),
    ]);
  }
}
