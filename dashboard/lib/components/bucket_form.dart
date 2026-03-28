import 'package:vanestack_common/vanestack_common.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/buckets.dart';
import '../utils/toast.dart';
import 'progress_indicator.dart';
import 'sheet.dart';

class BucketForm extends StatefulComponent {
  final Bucket? bucket;
  BucketForm({super.key, this.bucket});
  @override
  State<StatefulComponent> createState() => _BucketFormState();
}

class _BucketFormState extends State<BucketForm> {
  bool _saving = false;
  bool _deleting = false;
  final Map<String, int> _ruleResetCounters = {};

  final _form = Form({
    'name': FormControl<String>(initialValue: '', validators: [required(), urlFriendly()]),
    'listRule': FormControl<String?>(initialValue: null),
    'viewRule': FormControl<String?>(initialValue: null),
    'createRule': FormControl<String?>(initialValue: null),
    'updateRule': FormControl<String?>(initialValue: null),
    'deleteRule': FormControl<String?>(initialValue: null),
  });

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
      final name = _form.getControl<String>('name')!.value;
      final listRule = _form.getControl<String?>('listRule')!.value;
      final viewRule = _form.getControl<String?>('viewRule')!.value;
      final createRule = _form.getControl<String?>('createRule')!.value;
      final updateRule = _form.getControl<String?>('updateRule')!.value;
      final deleteRule = _form.getControl<String?>('deleteRule')!.value;

      Bucket bucket;
      if (component.bucket == null) {
        bucket = await context
            .read(bucketsProvider.notifier)
            .createBucket(
              bucketName: name,
              listRule: listRule,
              viewRule: viewRule,
              createRule: createRule,
              updateRule: updateRule,
              deleteRule: deleteRule,
            );
      } else {
        final newBucketName = name != component.bucket!.name ? name : null;
        bucket = await context
            .read(bucketsProvider.notifier)
            .updateBucket(
              component.bucket!.name,
              newBucketName: newBucketName,
              listRule: listRule,
              viewRule: viewRule,
              createRule: createRule,
              updateRule: updateRule,
              deleteRule: deleteRule,
            );
      }

      showToast(
        category: ToastCategory.success,
        title: 'Bucket saved successfully',
      );

      Sheet.of(context)?.close();
      Router.of(context).push('/_/storage/${bucket.name}');
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to save bucket',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await context.read(bucketsProvider.notifier).deleteBucket(component.bucket!.name);

      showToast(
        category: ToastCategory.success,
        title: 'Bucket deleted successfully',
      );

      Router.of(context).push('/_/storage');
      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to delete bucket',
        description: e.message,
      );
    } finally {
      setState(() => _deleting = false);
    }
  }

  @override
  void didUpdateComponent(covariant BucketForm oldComponent) {
    super.didUpdateComponent(oldComponent);
    _form.setValue({
      'name': component.bucket?.name ?? '',
      'listRule': component.bucket?.listRule,
      'viewRule': component.bucket?.viewRule,
      'createRule': component.bucket?.createRule,
      'updateRule': component.bucket?.updateRule,
      'deleteRule': component.bucket?.deleteRule,
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Component _buildRuleInput({
    required String path,
    required String ruleLabel,
    required String description,
    required String icon,
  }) {
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
              div(key: ValueKey('${path}_${_ruleResetCounters[path] ?? 0}'), classes: 'relative', [
                textarea(
                  [Component.text(field.value ?? '')],
                  name: 'rule${ruleLabel.replaceAll(' ', '')}',
                  classes: 'textarea font-mono text-sm ${field.value != null ? 'pt-8' : ''}',
                  rows: 2,
                  onInput: (v) => field.setValue(v),
                  attributes: {
                    'placeholder': field.value == null ? 'Superusers only' : 'e.g. request.auth.id != null',
                    'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                  },
                ),
                if (field.value != null)
                  button(
                    classes:
                        'absolute top-1.5 right-1.5 px-2 py-1 text-[10px] font-medium text-muted-foreground hover:text-foreground hover:bg-muted/80 border border-transparent hover:border-border rounded transition-colors flex items-center gap-1',
                    events: events(onClick: () {
                      field.setValue(null);
                      setState(() => _ruleResetCounters[path] = (_ruleResetCounters[path] ?? 0) + 1);
                    }),
                    [i(classes: 'icon-lock text-[10px]', []), Component.text('Set Superusers only')],
                  ),
              ]),
              if (field.isTouched && field.error != null)
                p(
                  classes: 'text-destructive text-sm',
                  attributes: {'role': 'alert'},
                  [Component.text(field.error!)],
                ),
            ]),
          ]),
        ]),
      ]),
    );
  }

  @override
  Component build(BuildContext context) {
    return FormBuilder(
      form: _form,
      builder: (context, form) => Component.fragment([
        div(
          classes: 'px-6 py-4 border-b border-border flex justify-between items-center bg-muted',
          [
            div([
              h2(classes: 'text-xl font-bold text-foreground', [
                Component.text(
                  component.bucket == null ? 'Create Bucket' : 'Edit Bucket',
                ),
              ]),
              p(classes: 'text-xs text-muted-foreground mt-1', [
                Component.text('Configure bucket settings and access rules.'),
              ]),
            ]),
            div(classes: 'flex gap-2', [
              button(
                id: 'deleteBtn',
                classes: 'btn-icon-ghost hover:text-destructive ${component.bucket == null ? 'hidden' : ''}',
                events: events(onClick: _delete),
                [
                  if (_deleting) const ProgressIndicator() else i(classes: 'icon-trash', []),
                ],
              ),
              button(
                classes: 'btn-icon-ghost',
                events: events(onClick: () => Sheet.of(context)?.close()),
                [i(classes: 'icon-x', [])],
              ),
            ]),
          ],
        ),
        div(classes: 'flex-1 overflow-y-auto sheet-content', [
          section(classes: 'px-6 py-4 border-b border-border bg-card', [
            FormFieldBuilder<FormControl<String>>(
              path: 'name',
              builder: (context, field) => label(
                classes: 'field label grid gap-2',
                [
                  Component.text('Bucket Name'),
                  input<String>(
                    name: 'bucketName',
                    classes: 'input',
                    type: InputType.text,
                    value: field.value,
                    onInput: (v) => field.setValue(v),
                    attributes: {
                      'placeholder': 'e.g. my-bucket, user_uploads',
                      'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                    },
                  ),
                  if (field.isTouched && field.error != null)
                    p(
                      classes: 'text-destructive text-sm',
                      attributes: {'role': 'alert'},
                      [Component.text(field.error!)],
                    ),
                ],
              ),
            ),
          ]),
          section(classes: 'space-y-4 px-6 py-4', [
            // Info banner
            div(classes: 'bg-warning/10 border border-warning/20 rounded-lg p-4 flex gap-3', [
              i(classes: 'icon-shield text-warning mt-0.5', []),
              div([
                p(classes: 'text-sm text-warning font-medium', [Component.text('Access Control Rules')]),
                p(classes: 'text-xs text-warning mt-1', [
                  Component.text(
                    'Define who can access this bucket. Leave empty to restrict access to superusers only. Use SQL expressions for custom rules.',
                  ),
                ]),
              ]),
            ]),

            // Rules
            _buildRuleInput(
              path: 'listRule',
              ruleLabel: 'List Rule',
              description: 'Who can list files in this bucket',
              icon: 'icon-list',
            ),
            _buildRuleInput(
              path: 'viewRule',
              ruleLabel: 'View Rule',
              description: 'Who can view/download individual files',
              icon: 'icon-eye',
            ),
            _buildRuleInput(
              path: 'createRule',
              ruleLabel: 'Create Rule',
              description: 'Who can upload new files',
              icon: 'icon-plus',
            ),
            _buildRuleInput(
              path: 'updateRule',
              ruleLabel: 'Update Rule',
              description: 'Who can replace existing files',
              icon: 'icon-pencil',
            ),
            _buildRuleInput(
              path: 'deleteRule',
              ruleLabel: 'Delete Rule',
              description: 'Who can delete files',
              icon: 'icon-trash',
            ),
          ]),
        ]),
        div(
          classes: 'px-6 py-4 border-t border-border bg-muted flex justify-end gap-3',
          [
            button(
              classes: 'btn-outline',
              events: events(onClick: () => Sheet.of(context)?.close()),
              [Component.text('Cancel')],
            ),
            button(
              classes: 'btn',
              events: events(onClick: _save),
              disabled: _saving,
              [
                if (_saving) const ProgressIndicator() else i([], classes: 'icon-check'),
                Component.text('Save Changes'),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
