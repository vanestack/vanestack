import 'dart:convert';

import 'package:vanestack_common/vanestack_common.dart';
import 'package:vanestack_dashboard/utils/extensions.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' hide Document;
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/documents.dart';
import '../utils/toast.dart';
import 'progress_indicator.dart';
import 'sheet.dart';

class DocumentForm extends StatefulComponent {
  final Document? document;
  final Collection collection;
  const DocumentForm({this.document, required this.collection, super.key});

  @override
  State<DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<DocumentForm> {
  bool _saving = false;
  bool _deleting = false;

  bool get _isView => component.collection is ViewCollection;

  final _date = DateFormat.yMd().add_Hms();

  late final Form _form;

  @override
  void initState() {
    super.initState();
    _form = _buildForm();
    _populateForm();
  }

  Form _buildForm() {
    final fields = <String, FormField>{
      'id': FormControl<String>(initialValue: ''),
    };

    for (final attr in component.collection.attributes) {
      if (['id', 'created_at', 'updated_at'].contains(attr.name)) continue;

      switch (attr) {
        case BoolAttribute():
          fields[attr.name] = FormControl<bool?>(
            initialValue: null,
            validators: attr.nullable ? [] : [_requiredBool()],
          );
        case IntAttribute():
          fields[attr.name] = FormControl<int?>(
            initialValue: null,
            validators: attr.nullable ? [] : [_requiredInt()],
          );
        case DoubleAttribute():
          fields[attr.name] = FormControl<double?>(
            initialValue: null,
            validators: attr.nullable ? [] : [_requiredDouble()],
          );
        case DateAttribute():
          fields[attr.name] = FormControl<int?>(
            initialValue: null,
            validators: attr.nullable ? [] : [_requiredInt()],
          );
        case JsonAttribute():
          fields[attr.name] = FormControl<String>(
            initialValue: '',
            validators: [_validJson()],
          );
        default:
          fields[attr.name] = FormControl<String>(
            initialValue: '',
            validators: attr.nullable ? [] : [required()],
          );
      }
    }

    return Form(fields);
  }

  void _populateForm() {
    final doc = component.document;
    if (doc == null) return;

    final values = <String, dynamic>{'id': doc.id};

    for (final attr in component.collection.attributes) {
      if (['id', 'created_at', 'updated_at'].contains(attr.name)) continue;

      final value = doc.data[attr.name];
      if (attr is JsonAttribute) {
        values[attr.name] = value != null ? jsonEncode(value) : '';
      } else {
        values[attr.name] = value;
      }
    }

    _form.setValue(values);
  }

  Validator<bool?> _requiredBool() {
    return (value, form) => value == null ? 'This field is required' : null;
  }

  Validator<int?> _requiredInt() {
    return (value, form) => value == null ? 'This field is required' : null;
  }

  Validator<double?> _requiredDouble() {
    return (value, form) => value == null ? 'This field is required' : null;
  }

  Validator<String> _validJson() {
    return (value, form) {
      if (value.isEmpty) return null;
      try {
        jsonDecode(value);
        return null;
      } catch (_) {
        return 'Invalid JSON';
      }
    };
  }

  Map<String, Object?> _getFormData() {
    final data = <String, Object?>{
      'id': _form.getControl<String>('id')!.value.nullIfEmpty,
    };

    for (final attr in component.collection.attributes) {
      if (['id', 'created_at', 'updated_at'].contains(attr.name)) continue;

      switch (attr) {
        case BoolAttribute():
          data[attr.name] = _form.getControl<bool?>(attr.name)?.value;
        case IntAttribute():
          data[attr.name] = _form.getControl<int?>(attr.name)?.value;
        case DoubleAttribute():
          data[attr.name] = _form.getControl<double?>(attr.name)?.value;
        case DateAttribute():
          data[attr.name] = _form.getControl<int?>(attr.name)?.value;
        case JsonAttribute():
          final jsonStr = _form.getControl<String>(attr.name)?.value ?? '';
          data[attr.name] = jsonStr.isEmpty ? null : jsonDecode(jsonStr);
        default:
          data[attr.name] = _form.getControl<String>(attr.name)?.value.nullIfEmpty;
      }
    }

    return data;
  }

  @override
  void didUpdateComponent(covariant DocumentForm oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.document != component.document) {
      _populateForm();
    }
  }

  Future<void> _save() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      showToast(
        category: ToastCategory.error,
        title: 'Invalid form data',
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final notifier = context.read(
        documentsProvider(component.collection.name).notifier,
      );

      final data = _getFormData();

      if (component.document == null) {
        await notifier.createDocument(
          data: {...data}..removeWhere((k, v) => k == 'id' && (v == null || (v is String && v.isEmpty))),
        );
        showToast(category: ToastCategory.success, title: "Document created");
      } else {
        await notifier.updateDocument(
          id: component.document!.id,
          data: {...data}..remove('id'),
        );

        showToast(category: ToastCategory.success, title: "Document updated");
      }

      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to save document',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (component.document == null) return;

    setState(() => _deleting = true);

    try {
      final notifier = context.read(
        documentsProvider(component.collection.name).notifier,
      );
      await notifier.deleteDocument(id: component.document!.id);

      showToast(category: ToastCategory.success, title: "Document deleted");

      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to delete document',
        description: e.message,
      );
    } finally {
      setState(() => _deleting = false);
    }
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Component _buildFieldForAttribute(Attribute attr) {
    return label(
      classes: "label flex flex-col sm:flex-row items-start sm:items-center gap-2",
      [
        div(classes: "w-full sm:w-36 flex flex-row sm:flex-col justify-between shrink-0", [
          div([
            span(classes: "text-xs font-semibold", [Component.text(attr.name)]),
            if (!attr.nullable)
              span(classes: "text-xs font-semibold text-destructive", [Component.text('*')]),
          ]),
          span(classes: "text-xs text-muted-foreground", [Component.text(attr.type)]),
        ]),
        if (attr is BoolAttribute)
          FormFieldBuilder<FormControl<bool?>>(
            path: attr.name,
            builder: (context, field) => div(classes: 'w-full grid gap-1', [
              select(
                classes: 'select w-full',
                [
                  option([], value: 'true', label: 'True', selected: field.value == true),
                  option([], value: 'false', label: 'False', selected: field.value == false),
                  if (attr.nullable) option([], value: '', label: 'null', selected: field.value == null),
                ],
                name: attr.name,
                disabled: _isView,
                value: field.value?.toString() ?? '',
                onChange: (v) {
                  final value = v.first;
                  field.setValue(switch (value) {
                    'true' => true,
                    'false' => false,
                    _ => null,
                  });
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
            ]),
          )
        else if (attr is IntAttribute)
          FormFieldBuilder<FormControl<int?>>(
            path: attr.name,
            builder: (context, field) => div(classes: 'w-full grid gap-1', [
              input<num?>(
                name: attr.name,
                classes: "input",
                type: InputType.number,
                disabled: _isView,
                value: field.value?.toString() ?? '',
                onInput: (v) => field.setValue(v?.toInt()),
                attributes: {
                  'step': '1',
                  'placeholder': 'NULL',
                  'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
            ]),
          )
        else if (attr is DoubleAttribute)
          FormFieldBuilder<FormControl<double?>>(
            path: attr.name,
            builder: (context, field) => div(classes: 'w-full grid gap-1', [
              input<num?>(
                name: attr.name,
                classes: "input",
                type: InputType.number,
                disabled: _isView,
                value: field.value?.toString() ?? '',
                onInput: (v) => field.setValue(v?.toDouble()),
                attributes: {
                  'step': 'any',
                  'placeholder': 'NULL',
                  'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
            ]),
          )
        else if (attr is DateAttribute)
          FormFieldBuilder<FormControl<int?>>(
            path: attr.name,
            builder: (context, field) => div(classes: 'w-full grid gap-1', [
              input<String>(
                name: attr.name,
                classes: "input",
                type: InputType.dateTimeLocal,
                disabled: _isView,
                value: field.value != null
                    ? DateTime.fromMillisecondsSinceEpoch(field.value! * 1000).toIso8601String()
                    : '',
                onInput: (v) {
                  final dt = DateTime.tryParse(v);
                  field.setValue(dt?.secondsSinceEpoch);
                },
                attributes: {
                  'placeholder': 'NULL',
                  'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
            ]),
          )
        else
          FormFieldBuilder<FormControl<String>>(
            path: attr.name,
            builder: (context, field) => div(classes: 'w-full grid gap-1', [
              input<String>(
                name: attr.name,
                classes: "input",
                type: InputType.text,
                disabled: _isView,
                value: field.value,
                onInput: (v) => field.setValue(v),
                attributes: {
                  'placeholder': 'NULL',
                  'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                },
              ),
              if (field.isTouched && field.error != null)
                p(classes: 'text-destructive text-sm', [Component.text(field.error!)]),
            ]),
          ),
      ],
    );
  }

  @override
  Component build(BuildContext context) {
    return FormBuilder(
      form: _form,
      builder: (context, form) => div(
        classes: "flex flex-col h-full",
        [
          // HEADER
          div(classes: "px-6 py-4 border-b bg-muted flex justify-between", [
            h2(classes: "text-lg font-bold", [
              Component.text(
                _isView
                    ? "View Document"
                    : component.document == null
                        ? "Create Document"
                        : "Edit Document",
              ),
            ]),
            div(classes: 'flex gap-2', [
              if (component.document != null && !_isView)
                button(
                  type: ButtonType.button,
                  id: 'deleteBtn',
                  classes: 'btn-icon-ghost hover:text-destructive',
                  events: events(onClick: _delete),
                  [
                    if (_deleting) const ProgressIndicator() else i(classes: 'icon-trash', []),
                  ],
                ),
              button(
                type: ButtonType.button,
                classes: "btn-icon-ghost",
                events: events(onClick: () => Sheet.of(context)?.close()),
                [i(classes: "icon-x", [])],
              ),
            ]),
          ]),

          // FORM CONTENT
          div(
            key: ValueKey(component.document?.id),
            classes: "p-6 space-y-6 flex-1 overflow-y-auto",
            [
              // ID (Disabled on update)
              FormFieldBuilder<FormControl<String>>(
                path: 'id',
                builder: (context, field) => label(
                  classes: "label flex flex-col sm:flex-row items-start sm:items-center gap-2",
                  [
                    div(classes: "w-full sm:w-36 flex flex-row sm:flex-col justify-between shrink-0", [
                      span(classes: "text-xs font-semibold", [Component.text('ID')]),
                      span(classes: "text-xs text-muted-foreground", [Component.text('UUID')]),
                    ]),
                    input<String>(
                      classes: "input",
                      type: InputType.text,
                      disabled: component.document != null || _isView,
                      value: field.value,
                      onInput: (v) => field.setValue(v),
                      attributes: {"placeholder": "Leave empty to auto-generate"},
                    ),
                  ],
                ),
              ),

              for (final attr in component.collection.attributes.where(
                (e) => !['id', 'created_at', 'updated_at'].contains(e.name),
              ))
                _buildFieldForAttribute(attr),

              if (component.document != null)
                div(classes: "text-xs text-muted-foreground space-y-1", [
                  if (component.document!.createdAt != null)
                    div([Component.text("Created: ${_date.format(component.document!.createdAt!)}")]),
                  if (component.document!.updatedAt != null)
                    div([Component.text("Updated: ${_date.format(component.document!.updatedAt!)}")]),
                ]),
            ],
          ),

          // FOOTER BUTTONS
          div(classes: "px-6 py-4 border-t bg-muted flex justify-end gap-3", [
            button(
              type: ButtonType.button,
              classes: _isView ? "btn" : "btn-outline",
              events: events(onClick: () => Sheet.of(context)?.close()),
              [Component.text(_isView ? "Close" : "Cancel")],
            ),
            if (!_isView)
              button(
                type: ButtonType.button,
                classes: "btn",
                disabled: _saving,
                events: events(onClick: _save),
                [
                  if (_saving) const ProgressIndicator(),
                  if (!_saving) i(classes: "icon-check", []),
                  Component.text("Save"),
                ],
              ),
          ]),
        ],
      ),
    );
  }
}
