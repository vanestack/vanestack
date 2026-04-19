import 'package:vanestack_client/vanestack_client.dart';
import 'package:vanestack_dashboard/providers/files.dart';

import 'package:intl/intl.dart';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'package:path/path.dart' show basename;
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/js_interop.dart' as web;
import 'package:universal_web/web.dart' as web;

import '../forms/components/form_builder.dart';
import '../forms/components/form_field_builder.dart';
import '../forms/reactive/reactive_forms.dart';
import '../providers/client.dart';
import '../utils/toast.dart';
import 'progress_indicator.dart';
import 'sheet.dart';

import 'dart:js_interop';

class FileForm extends StatefulComponent {
  final Bucket bucket;
  final File? file;
  final String currentPath;
  FileForm({super.key, required this.bucket, this.file, this.currentPath = ''});
  @override
  State<StatefulComponent> createState() => _FileFormState();
}

class _FileFormState extends State<FileForm> {
  bool _saving = false;
  bool _deleting = false;
  final _date = DateFormat.yMd().add_Hms();

  web.File? _selectedFile;
  web.AbortController? abortController;

  final _form = Form({
    'fileName': FormControl<String>(initialValue: ''),
  });

  Future<void> download() async {
    final client = context.read(clientProvider);
    final result = await client.files.getDownloadUrl(bucket: component.bucket.name, fileId: component.file!.id);

    web.window.open(result.url, '_blank');
  }

  Future<void> copyUrl() async {
    final client = context.read(clientProvider);
    final result = await client.files.getDownloadUrl(bucket: component.bucket.name, fileId: component.file!.id);

    await web.window.navigator.clipboard.writeText(result.url).toDart;

    showToast(
      category: ToastCategory.success,
      title: 'File URL copied to clipboard',
    );
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      showToast(
        category: ToastCategory.error,
        title: 'Please select a file to upload',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      // Using native fetch API for multipart upload to support large files
      final client = context.read(clientProvider);
      final uploadUrl = '${client.baseUrl}/v1/files/${component.bucket.name}/upload';
      final fileName = _form.getControl<String>('fileName')!.value;

      final web.FormData formData = web.FormData();

      formData.append('file', _selectedFile!, fileName);
      // Use current path from file browser (without trailing slash for the path field)
      final uploadPath = component.currentPath.isEmpty
          ? ''
          : component.currentPath.endsWith('/')
          ? component.currentPath.substring(0, component.currentPath.length - 1)
          : component.currentPath;
      formData.append('path', uploadPath.toJS);

      final headers = web.Headers();

      for (final entry in client.headers.entries) {
        //Content-Type is set automatically for multipart/form-data
        if (entry.key.toLowerCase() == 'content-type') continue;
        headers.append(entry.key, entry.value);
      }

      abortController = web.AbortController();

      final web.RequestInit requestInit = web.RequestInit(
        method: 'POST',
        headers: headers,
        body: formData,
        signal: abortController?.signal,
      );

      final response = await web.window
          .fetch(
            uploadUrl.toJS,
            requestInit,
          )
          .toDart;

      if (!response.ok) {
        final body = await response.text().toDart;
        throw VaneStackException(body.toDart);
      }

      showToast(
        category: ToastCategory.success,
        title: 'File uploaded successfully',
      );

      context.invalidate(listFilesProvider);
      _close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to upload file',
        description: e.message,
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      final client = context.read(clientProvider);
      await client.files.delete(
        bucket: component.bucket.name,
        path: component.file!.path,
      );

      showToast(
        category: ToastCategory.success,
        title: 'File deleted successfully',
      );

      context.invalidate(listFilesProvider);
      Sheet.of(context)?.close();
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to delete file',
        description: e.message,
      );
    } finally {
      setState(() => _deleting = false);
    }
  }

  void _close() {
    setState(() => _selectedFile = null);
    _form.reset();
    abortController?.abort();
    Sheet.of(context)?.close();
  }

  @override
  void initState() {
    super.initState();
    _form.setValue({'fileName': basename(component.file?.path ?? '')});
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  String formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    final factor = 1024;

    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= factor && unitIndex < units.length - 1) {
      size /= factor;
      unitIndex++;
    }

    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
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
                  component.file == null ? 'Upload File' : 'File Details',
                ),
              ]),
            ]),
            div(classes: 'flex gap-2', [
              if (component.file != null)
                button(
                  id: 'deleteBtn',
                  classes: 'btn-icon-ghost hover:text-destructive',
                  events: events(onClick: _delete),
                  [
                    if (_deleting) const ProgressIndicator() else i(classes: 'icon-trash', []),
                  ],
                ),
              button(
                classes: 'btn-icon-ghost',
                events: events(onClick: _close),
                [i(classes: 'icon-x', [])],
              ),
            ]),
          ],
        ),
        div(classes: 'flex-1 overflow-y-auto p-6 sheet-content space-y-8', [
          if (component.file != null)
            div(classes: ' border-border rounded-lg bg-card shadow-sm font-sans', [
              div(
                classes: 'flex flex-col items-center justify-center p-8 bg-muted rounded-t-lg border-b border-border',
                [
                  div(classes: 'w-20 h-20 flex items-center justify-center', [
                    i(
                      classes:
                          'text-[3rem]! text-muted-foreground leading-none ${switch (component.file?.mimeType) {
                            'image/png' || 'image/jpeg' || 'image/gif' => 'icon-image',
                            'application/pdf' => 'icon-file-text',
                            'text/plain' => 'icon-file-type-corner',
                            'application/zip' || 'application/x-tar' || 'application/gzip' => 'icon-file-speadsheet',
                            'video/mp4' || 'video/mpeg' => 'icon-file-play',
                            'audio/mpeg' || 'audio/wav' => 'icon-file-headphone',
                            _ => 'icon-file',
                          }}',
                      [],
                    ),
                  ]),
                  h3(classes: 'text-lg font-bold text-foreground truncate w-full text-center px-4', [
                    Component.text(basename(component.file!.path)),
                  ]),
                  span(classes: 'text-xs font-medium text-muted-foreground uppercase tracking-wider mb-4', [
                    Component.text(formatFileSize(component.file!.size)),
                  ]),
                ],
              ),
              div(classes: 'flex justify-end gap-2 p-4 border-b border-border', [
                button(
                  onClick: download,
                  classes: 'btn-secondary',
                  [Component.text('Download')],
                ),
                button(
                  onClick: copyUrl,
                  classes: 'btn-outline',
                  [Component.text('Copy URL')],
                ),
              ]),
              div(classes: 'p-4 space-y-3', [
                div(classes: 'flex justify-between text-sm', [
                  span(classes: 'text-muted-foreground', [Component.text('Created')]),
                  span(classes: 'text-foreground font-medium', [
                    Component.text(_date.format(component.file!.createdAt)),
                  ]),
                ]),
                div(classes: 'flex justify-between text-sm', [
                  span(classes: 'text-muted-foreground', [Component.text('Last Modified')]),
                  span(classes: 'text-foreground font-medium', [
                    Component.text(_date.format(component.file!.updatedAt)),
                  ]),
                ]),
                div(classes: 'flex justify-between text-sm pt-2 border-t border-border', [
                  span(classes: 'text-muted-foreground', [Component.text('File ID')]),
                  code(classes: 'text-xs badge-secondary', [Component.text(component.file!.id)]),
                ]),
              ]),
            ])
          else
            div(classes: 'form grid gap-6', [
              if (component.currentPath.isNotEmpty)
                div(classes: 'text-sm text-muted-foreground', [
                  Component.text('Uploading file in: '),
                  code(classes: 'badge-secondary', [Component.text(component.currentPath)]),
                ]),
              label(classes: 'grid gap-2', [
                Component.text('File'),
                input<List<web.File>>(
                  type: InputType.file,
                  onInput: (files) {
                    setState(() {
                      _selectedFile = files.isNotEmpty ? files.first : null;
                    });
                    _form.getControl<String>('fileName')!.setValue(_selectedFile?.name ?? '');
                  },
                ),
              ]),
              FormFieldBuilder<FormControl<String>>(
                path: 'fileName',
                builder: (context, field) => label(classes: 'grid gap-2', [
                  Component.text('Name'),
                  input<String>(
                    type: InputType.text,
                    classes: 'input',
                    value: field.value,
                    onInput: (v) => field.setValue(v),
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
            if (component.file == null)
              button(
                classes: 'btn',
                events: events(onClick: _upload),
                disabled: _saving,
                [
                  if (_saving) const ProgressIndicator() else i([], classes: 'icon-upload'),
                  Component.text('Upload File'),
                ],
              ),
          ],
        ),
      ]),
    );
  }
}
