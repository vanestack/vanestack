import 'package:vanestack_client/vanestack_client.dart';
import 'package:vanestack_dashboard/providers/files.dart';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../forms/validators.dart';
import '../providers/client.dart';
import '../utils/toast.dart';
import 'progress_indicator.dart';
import 'sheet.dart';

Validator<String> noSlashes([String? message]) {
  return (value, form) {
    if (value.contains('/')) {
      return message ?? 'Folder name cannot contain "/"';
    }
    return null;
  };
}

class FolderForm extends StatefulComponent {
  final Bucket bucket;
  final String currentPath;

  FolderForm({super.key, required this.bucket, required this.currentPath});

  @override
  State<StatefulComponent> createState() => _FolderFormState();
}

class _FolderFormState extends State<FolderForm> {
  bool _saving = false;

  final _form = Form({
    'folderName': FormControl<String>(
      initialValue: '',
      validators: [required('Please enter a folder name'), noSlashes()],
    ),
  });

  Future<void> _createFolder() async {
    _form.markAllAsTouched();
    if (!_form.validate()) {
      return;
    }

    setState(() => _saving = true);
    try {
      final client = context.read(clientProvider);
      final folderName = _form.getControl<String>('folderName')!.value.trim();

      // Build the path for the marker file
      final basePath = component.currentPath.isEmpty
          ? folderName
          : component.currentPath.endsWith('/')
              ? '${component.currentPath}$folderName'
              : '${component.currentPath}/$folderName';

      final uploadUrl = '${client.baseUrl}/v1/files/${component.bucket.name}/upload';

      // Create an empty blob for the marker file
      final emptyBlob = web.Blob(<JSUint8Array>[].toJS);
      final web.FormData formData = web.FormData();

      formData.append('file', emptyBlob, '.create_folder');
      formData.append('path', basePath.toJS);

      final headers = web.Headers();
      for (final entry in client.headers.entries) {
        if (entry.key.toLowerCase() == 'content-type') continue;
        headers.append(entry.key, entry.value);
      }

      final web.RequestInit requestInit = web.RequestInit(
        method: 'POST',
        headers: headers,
        body: formData,
      );

      await web.window
          .fetch(
            uploadUrl.toJS,
            requestInit,
          )
          .toDart;

      showToast(
        category: ToastCategory.success,
        title: 'Folder created successfully',
      );

      context.invalidate(listFilesProvider);
      _close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to create folder',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  void _close() {
    _form.reset();
    Sheet.of(context)?.close();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
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
                Component.text('Create Folder'),
              ]),
            ]),
            div(classes: 'flex gap-2', [
              button(
                classes: 'btn-icon-ghost',
                events: events(onClick: _close),
                [i(classes: 'icon-x', [])],
              ),
            ]),
          ],
        ),
        div(classes: 'flex-1 overflow-y-auto p-6 sheet-content space-y-8', [
          div(classes: 'form grid gap-6', [
            if (component.currentPath.isNotEmpty)
              div(classes: 'text-sm text-muted-foreground', [
                Component.text('Creating folder in: '),
                code(classes: 'badge-secondary', [
                  Component.text(component.currentPath),
                ]),
              ]),
            FormFieldBuilder<FormControl<String>>(
              path: 'folderName',
              builder: (context, field) => label(classes: 'grid gap-2', [
                Component.text('Folder Name'),
                input<String>(
                  type: InputType.text,
                  classes: 'input',
                  value: field.value,
                  attributes: {
                    'placeholder': 'Enter folder name',
                    'aria-invalid': field.isTouched && field.error != null ? 'true' : 'false',
                  },
                  onInput: (v) => field.setValue(v),
                ),
                if (field.isTouched && field.error != null)
                  p(
                    classes: 'text-destructive text-sm',
                    [Component.text(field.error!)],
                  ),
              ]),
            ),
          ]),
        ]),
        div(
          classes: 'px-6 py-4 border-t border-border bg-muted flex justify-end gap-3',
          [
            button(
              classes: 'btn-outline',
              events: events(onClick: _close),
              [Component.text('Cancel')],
            ),
            button(
              classes: 'btn',
              events: events(onClick: _createFolder),
              disabled: _saving,
              [
                if (_saving) const ProgressIndicator() else i([], classes: 'icon-folder-plus'),
                Component.text('Create Folder'),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
