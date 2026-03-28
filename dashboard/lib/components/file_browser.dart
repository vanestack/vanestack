import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:path/path.dart' show basename, join;

import '../providers/files.dart';
import 'popover.dart';
import 'progress_indicator.dart';

class FileBrowser extends StatefulComponent {
  final Bucket bucket;
  final void Function(File) onFileClick;
  final void Function(File) onFileDelete;
  final void Function(String folderPath) onFolderDelete;

  const FileBrowser({
    super.key,
    required this.bucket,
    required this.onFileClick,
    required this.onFileDelete,
    required this.onFolderDelete,
  });

  @override
  State<FileBrowser> createState() => _ColumnBrowserState();
}

class _ColumnBrowserState extends State<FileBrowser> {
  void selectFolder(int columnIndex, String folderName, List<String> currentSegments) {
    final newSegments = [...currentSegments.take(columnIndex), folderName];
    final path = '${newSegments.join('/')}/';
    context.read(currentPathProvider(component.bucket.name).notifier).set(path);
  }

  List<String> _parsePathSegments(String currentPath) {
    if (currentPath.isEmpty) return [];
    final path = currentPath.endsWith('/') ? currentPath.substring(0, currentPath.length - 1) : currentPath;
    return path.split('/');
  }

  String getPrefix(int columnIndex, List<String> pathSegments) {
    if (columnIndex == 0) return '';
    return '${pathSegments.take(columnIndex).join('/')}/';
  }

  @override
  Component build(BuildContext context) {
    final currentPath = context.watch(currentPathProvider(component.bucket.name));
    final pathSegments = _parsePathSegments(currentPath);

    final columnCount = pathSegments.length + 1;

    return div(
      classes: 'flex flex-row h-full overflow-x-auto bg-muted',
      [
        for (var i = 0; i < columnCount; i++)
          _BrowserColumn(
            key: ValueKey('column-$i-${getPrefix(i, pathSegments)}'),
            bucket: component.bucket.name,
            prefix: getPrefix(i, pathSegments),
            selectedFolder: i < pathSegments.length ? pathSegments[i] : null,
            onFolderClick: (folderName) => selectFolder(i, folderName, pathSegments),
            onFileClick: component.onFileClick,
            onFolderDelete: component.onFolderDelete,
            onFileDelete: component.onFileDelete,
          ),
      ],
    );
  }
}

class _BrowserColumn extends StatelessComponent {
  final String bucket;
  final String prefix;
  final String? selectedFolder;
  final void Function(String) onFolderClick;
  final void Function(File) onFileClick;
  final void Function(String) onFolderDelete;
  final void Function(File) onFileDelete;

  const _BrowserColumn({
    super.key,
    required this.bucket,
    required this.prefix,
    required this.selectedFolder,
    required this.onFolderClick,
    required this.onFileClick,
    required this.onFolderDelete,
    required this.onFileDelete,
  });

  String _getFileIcon(String mimeType) {
    if (mimeType.startsWith('image/')) return 'icon-image';
    if (mimeType == 'application/pdf') return 'icon-file-text';
    if (mimeType.startsWith('text/')) return 'icon-file-text';
    if (mimeType.startsWith('video/')) return 'icon-film';
    if (mimeType.startsWith('audio/')) return 'icon-music';
    if (mimeType.contains('zip') || mimeType.contains('archive')) {
      return 'icon-archive';
    }
    return 'icon-file';
  }

  @override
  Component build(BuildContext context) {
    final asyncValue = context.watch(listFilesProvider((bucket, prefix)));

    return div(
      classes: 'w-64 h-full border-r border-border bg-card shrink-0 flex flex-col',
      [
        asyncValue.when(
          loading: () => div(
            classes: 'flex-1 flex items-center justify-center',
            [ProgressIndicator()],
          ),
          error: (e, _) => div(
            classes: 'flex-1 flex items-center justify-center text-destructive p-4',
            [Component.text('Error loading files')],
          ),
          data: (items) {
            if (items.folders.isEmpty && items.files.isEmpty) {
              return div(
                classes: 'flex-1 flex items-center justify-center text-muted-foreground p-4 text-center text-sm',
                [Component.text('Empty folder')],
              );
            }

            return div(
              classes: 'flex-1 overflow-y-auto',
              [
                for (final folder in items.folders) _buildFolderItem(folder),
                for (final file in items.files) _buildFileItem(file),
              ],
            );
          },
        ),
      ],
    );
  }

  Component _buildFolderItem(String folderName) {
    final isSelected = folderName == selectedFolder;

    return div(
      key: ValueKey('folder-$folderName'),
      classes:
          'group flex items-center gap-2 px-3 py-2 cursor-pointer hover:bg-accent text-sm font-medium transition-colors text-muted-foreground hover:text-foreground ${isSelected ? 'bg-muted text-accent-foreground' : ''}',
      events: events(
        onClick: () => onFolderClick(folderName),
      ),
      [
        i(classes: 'icon-folder shrink-0', []),
        span(classes: 'truncate flex-1', [Component.text(folderName)]),
        Popover(
          side: 'bottom',
          align: 'end',
          child: button(
            [
              i(
                classes:
                    'icon-ellipsis-vertical shrink-0 text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity duration-300',
                [],
              ),
            ],
          ),
          children: [
            button(classes: 'btn-sm-ghost w-full', [
              i([], classes: 'icon-trash'),
              Component.text('Delete'),
            ], onClick: () => onFolderDelete(join(prefix, folderName))),
          ],
        ),
      ],
    );
  }

  Component _buildFileItem(File file) {
    final fileName = basename(file.path);

    return div(
      key: ValueKey('file-${file.id}'),
      classes:
          'flex items-center gap-2 px-3 py-2 cursor-pointer text-sm font-medium transition-colors hover:bg-accent text-muted-foreground hover:text-foreground',
      events: events(
        onClick: () => onFileClick(file),
      ),
      [
        i(classes: '${_getFileIcon(file.mimeType)} shrink-0', []),
        span(classes: 'truncate flex-1', [Component.text(fileName)]),
        Popover(
          side: 'bottom',
          align: 'end',
          child: button(
            [
              i(
                classes:
                    'icon-ellipsis-vertical shrink-0 text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity duration-300',
                [],
              ),
            ],
          ),
          children: [
            button(classes: 'btn-sm-ghost w-full', [
              i([], classes: 'icon-trash'),
              Component.text('Delete'),
            ], onClick: () => onFileDelete(file)),
          ],
        ),
      ],
    );
  }
}
