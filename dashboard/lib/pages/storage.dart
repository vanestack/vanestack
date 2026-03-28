import 'package:collection/collection.dart';
import 'package:vanestack_client/vanestack_client.dart';
import 'package:vanestack_dashboard/components/file_browser.dart';

import 'package:vanestack_dashboard/providers/files.dart';
import 'package:jaspr/dom.dart' hide Filter;
import 'package:jaspr/jaspr.dart' hide Document;
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/bucket_form.dart';
import '../components/bucket_menu_item.dart';
import '../components/empty.dart';
import '../components/file_form.dart';
import '../components/folder_form.dart';
import '../components/menu_button.dart';
import '../components/progress_indicator.dart';
import '../components/refresh_icon_button.dart';
import '../components/sheet.dart';
import '../providers/buckets.dart';
import '../providers/client.dart';
import '../utils/toast.dart';

class StoragePage extends StatefulComponent {
  final String? selectedBucket;

  const StoragePage({super.key, this.selectedBucket});

  @override
  State<StatefulComponent> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  bool bucketSheetOpen = false;
  bool fileSheetOpen = false;
  bool folderSheetOpen = false;
  bool mobileSidebarOpen = false;
  Bucket? _sheetBucket;
  File? _sheetFile;

  Future<void> _deleteFile(File file) async {
    try {
      final client = context.read(clientProvider);
      await client.files.delete(
        bucket: component.selectedBucket!,
        path: file.path,
      );
      showToast(
        category: ToastCategory.success,
        title: 'File deleted successfully',
      );
      context.invalidate(listFilesProvider);
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to delete file',
        description: e.message,
      );
    }
  }

  Future<void> _deleteFolder(String folderPath) async {
    try {
      final client = context.read(clientProvider);

      await client.files.delete(bucket: component.selectedBucket!, path: folderPath);

      showToast(
        category: ToastCategory.success,
        title: 'Folder deleted successfully',
      );
      context.invalidate(listFilesProvider);
    } on VaneStackException catch (e) {
      showToast(
        category: ToastCategory.error,
        title: 'Failed to delete folder',
        description: e.message,
      );
    }
  }

  List<Component> _buildBreadcrumbSegments(
    String bucketName,
    List<String> pathSegments,
  ) {
    final segments = <Component>[];

    Component buildChevron() {
      return li([
        i(classes: 'icon-chevron-right size-3.5', []),
      ]);
    }

    Component buildEllipsis() {
      return li(classes: 'inline-flex items-center gap-1.5', [
        span(classes: 'text-muted-foreground', [Component.text('...')]),
      ]);
    }

    // Pre-compute all segment data to avoid closure issues
    final segmentData = <({String label, String targetPath, bool isLast})>[];
    for (var i = 0; i < pathSegments.length; i++) {
      segmentData.add((
        label: pathSegments[i],
        targetPath: '${pathSegments.take(i + 1).join('/')}/',
        isLast: i == pathSegments.length - 1,
      ));
    }

    // Build a segment component from pre-computed data
    Component buildSegmentFromData(({String label, String targetPath, bool isLast}) data) {
      return li(
        key: ValueKey('breadcrumb-${data.targetPath}'),
        classes: 'inline-flex items-center gap-1.5',
        [
          span(
            classes: data.isLast
                ? 'text-foreground font-medium'
                : 'hover:text-foreground transition-colors cursor-pointer',
            events: data.isLast
                ? null
                : events(
                    onClick: () {
                      context.read(currentPathProvider(bucketName).notifier).set(data.targetPath);
                    },
                  ),
            [Component.text(data.label)],
          ),
        ],
      );
    }

    // If 4 or fewer segments, show all
    if (pathSegments.length < 4) {
      for (final data in segmentData) {
        segments.add(buildChevron());
        segments.add(buildSegmentFromData(data));
      }
    } else {
      // Show first segment
      segments.add(buildChevron());
      segments.add(buildSegmentFromData(segmentData[0]));

      // Show ellipsis
      segments.add(buildChevron());
      segments.add(buildEllipsis());

      // Show last two segments
      final lastTwoIndex = pathSegments.length - 2;
      for (var i = lastTwoIndex; i < pathSegments.length; i++) {
        segments.add(buildChevron());
        segments.add(buildSegmentFromData(segmentData[i]));
      }
    }

    return segments;
  }

  @override
  Component build(BuildContext context) {
    final buckets = context.watch(bucketsProvider);
    return Component.fragment([
      buckets.when(
        error: (e, stackTrace) => Component.empty(),
        loading: () => div(classes: 'h-full flex items-center justify-center', [
          ProgressIndicator(),
        ]),
        data: (buckets) {
          // Auto-select first bucket if none selected
          if (buckets.isNotEmpty && component.selectedBucket == null) {
            Future.microtask(() {
              Router.of(context).push('/_/storage/${buckets.first.name}');
            });
            return div(classes: 'h-full flex items-center justify-center', [
              ProgressIndicator(),
            ]);
          }

          if (buckets.isEmpty) {
            return div(classes: 'h-full flex flex-col', [
              // Mobile appbar
              div(
                classes: 'md:hidden h-16 bg-card border-b border-border shrink-0 px-4 flex items-center',
                [
                  MenuButton(),
                  h1(
                    classes: 'text-2xl font-semibold ml-2',
                    [Component.text('Storage')],
                  ),
                ],
              ),
              div(classes: 'flex-1 flex items-center justify-center', [
                Empty(
                  icon: 'folder',
                  title: 'No Buckets',
                  description: 'Get started by creating your first bucket.',
                  button: button(
                    classes: 'btn',
                    [
                      i([], classes: 'icon-plus'),
                      Component.text('Create Bucket'),
                    ],
                    onClick: () => setState(() {
                      _sheetBucket = null;
                      bucketSheetOpen = true;
                    }),
                  ),
                ),
              ]),
            ]);
          }

          return div(classes: 'h-full w-full flex relative', [
            // Mobile bottom sheet backdrop
            div(
              classes:
                  'fixed inset-0 bg-black/50 z-30 transition-opacity duration-300 md:hidden ${mobileSidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'}',
              events: events(onClick: () => setState(() => mobileSidebarOpen = false)),
              [],
            ),
            // Mobile bottom sheet
            div(
              classes:
                  'md:hidden fixed inset-x-0 bottom-0 z-40 bg-card rounded-t-2xl shadow-2xl '
                  'transition-transform duration-300 ease-out max-h-[70vh] flex flex-col '
                  '${mobileSidebarOpen ? 'translate-y-0' : 'translate-y-full'}',
              [
                // Handle bar
                div(classes: 'flex justify-center py-3', [
                  div(classes: 'w-10 h-1 bg-muted rounded-full', []),
                ]),
                // Header
                div(
                  classes: 'px-4 pb-3 flex items-center justify-between border-b border-border',
                  [
                    span(classes: 'font-semibold text-foreground', [
                      Component.text('Buckets'),
                    ]),
                    button(
                      classes: 'p-2 rounded-md hover:bg-accent',
                      events: events(onClick: () => setState(() => mobileSidebarOpen = false)),
                      [i(classes: 'icon-x text-muted-foreground', [])],
                    ),
                  ],
                ),
                // Content
                div(classes: 'p-4 space-y-2 overflow-y-auto flex-1', [
                  for (final bucket in buckets)
                    div(
                      events: events(onClick: () => setState(() => mobileSidebarOpen = false)),
                      [
                        BucketMenuItem(
                          label: bucket.name,
                          icon: 'folder',
                          active: bucket.name == component.selectedBucket,
                          to: '/_/storage/${bucket.name}',
                        ),
                      ],
                    ),
                  button(
                    [
                      i([], classes: 'icon-plus'),
                      Component.text('New Bucket'),
                    ],
                    classes: 'w-full btn-ghost mt-1',
                    onClick: () => setState(() {
                      _sheetBucket = null;
                      bucketSheetOpen = true;
                      mobileSidebarOpen = false;
                    }),
                  ),
                ]),
              ],
            ),
            // Desktop sidebar
            nav(
              classes: 'hidden md:block bg-card border-r border-border shrink-0 w-56 h-full',
              [
                div(classes: 'p-4 space-y-2 overflow-y-auto', [
                  for (final bucket in buckets)
                    BucketMenuItem(
                      label: bucket.name,
                      icon: 'folder',
                      active: bucket.name == component.selectedBucket,
                      to: '/_/storage/${bucket.name}',
                    ),
                  button(
                    [
                      i([], classes: 'icon-plus'),
                      Component.text('New Bucket'),
                    ],
                    classes: 'w-full btn-ghost mt-1',
                    onClick: () => setState(() {
                      _sheetBucket = null;
                      bucketSheetOpen = true;
                    }),
                  ),
                ]),
              ],
            ),
            Builder(
              builder: (context) {
                final bucket = buckets.firstWhereOrNull(
                  (c) => c.name == component.selectedBucket,
                );

                if (bucket == null) {
                  return div(classes: 'flex-1 flex flex-col', [
                    // Mobile appbar
                    div(
                      classes: 'md:hidden h-16 bg-card border-b border-border shrink-0 px-4 flex items-center',
                      [
                        MenuButton(),
                        h1(
                          classes: 'text-2xl font-semibold ml-2',
                          [Component.text('Storage')],
                        ),
                      ],
                    ),
                    Empty(
                      icon: 'mouse-pointer-click',
                      title: 'Select a bucket',
                      description: 'Please select a bucket from the list.',
                      button: button(
                        classes: 'btn md:hidden',
                        events: events(onClick: () => setState(() => mobileSidebarOpen = true)),
                        [
                          Component.text('Select Bucket'),
                        ],
                      ),
                    ),
                  ]);
                }

                final currentPath = context.watch(currentPathProvider(bucket.name));
                final pathSegments = currentPath.isEmpty
                    ? <String>[]
                    : currentPath.endsWith('/')
                    ? currentPath.substring(0, currentPath.length - 1).split('/')
                    : currentPath.split('/');

                return div(
                  classes: "flex flex-col flex-1 h-full overflow-hidden",
                  [
                    // Header - responsive
                    div(
                      classes:
                          'bg-card border-b border-border shrink-0 px-4 py-3 md:py-0 md:h-16 flex flex-col md:flex-row md:items-center justify-between gap-3',
                      [
                        // Breadcrumbs row with mobile menu button
                        div(classes: 'flex items-center gap-2 min-w-0 flex-1', [
                          // Mobile: burger menu
                          MenuButton(classes: 'md:hidden shrink-0'),
                          // Mobile: bucket name with chevron to open sidebar
                          button(
                            classes:
                                'md:hidden flex items-center gap-1 hover:bg-accent rounded-md px-2 py-1 shrink-0',
                            events: events(onClick: () => setState(() => mobileSidebarOpen = true)),
                            [
                              span(classes: 'text-xl font-semibold', [
                                Component.text(bucket.name),
                              ]),
                              i(classes: 'icon-chevron-down text-muted-foreground', []),
                            ],
                          ),
                          // Desktop: Breadcrumbs
                          ol(
                            classes:
                                'hidden md:flex text-muted-foreground overflow-hidden items-center gap-1.5 text-sm break-all sm:gap-2.5 min-w-0',
                            [
                              // Bucket name (root)
                              li(classes: 'inline-flex items-center gap-1.5', [
                                span(
                                  classes: pathSegments.isEmpty
                                      ? 'text-foreground font-medium'
                                      : 'hover:text-foreground transition-colors cursor-pointer',
                                  events: pathSegments.isEmpty
                                      ? null
                                      : events(
                                          onClick: () {
                                            context.read(currentPathProvider(bucket.name).notifier).set('');
                                          },
                                        ),
                                  [Component.text(bucket.name)],
                                ),
                              ]),
                              // Path segments with ellipsis for long paths
                              ..._buildBreadcrumbSegments(
                                bucket.name,
                                pathSegments,
                              ),
                            ],
                          ),
                        ]),
                        // Action buttons
                        div(classes: 'flex items-center gap-2 flex-wrap', [
                          RefreshIconButton(
                            onClick: () async {
                              context.invalidate(listFilesProvider);
                            },
                          ),
                          button(
                            classes: 'btn-outline flex-1 md:flex-none',
                            [
                              i([], classes: 'icon-folder-plus'),
                              span(classes: 'hidden sm:inline', [
                                Component.text('New Folder'),
                              ]),
                              span(classes: 'sm:hidden', [
                                Component.text('Folder'),
                              ]),
                            ],
                            onClick: () => setState(() {
                              folderSheetOpen = true;
                            }),
                          ),
                          button(
                            classes: 'btn-outline flex-1 md:flex-none',
                            [
                              i([], classes: 'icon-upload'),
                              Component.text('Upload'),
                            ],
                            onClick: () => setState(() {
                              _sheetFile = null;
                              fileSheetOpen = true;
                            }),
                          ),
                          button(
                            key: ValueKey(bucket.name),
                            classes: 'btn flex-1 md:flex-none',
                            [
                              i([], classes: 'icon-pencil'),
                              Component.text('Edit'),
                            ],
                            onClick: () => setState(() {
                              _sheetBucket = bucket;
                              bucketSheetOpen = true;
                            }),
                          ),
                        ]),
                      ],
                    ),
                    FileBrowser(
                      bucket: bucket,
                      onFileClick: (file) => setState(() {
                        _sheetFile = file;
                        fileSheetOpen = true;
                      }),
                      onFileDelete: _deleteFile,
                      onFolderDelete: _deleteFolder,
                    ),
                    Sheet(
                      child: FileForm(
                        bucket: bucket,
                        file: _sheetFile,
                        currentPath: currentPath,
                      ),
                      isOpen: fileSheetOpen,
                      onClose: () => setState(() {
                        fileSheetOpen = false;
                        _sheetFile = null;
                      }),
                    ),
                    Sheet(
                      child: FolderForm(
                        bucket: bucket,
                        currentPath: currentPath,
                      ),
                      isOpen: folderSheetOpen,
                      onClose: () => setState(() {
                        folderSheetOpen = false;
                      }),
                    ),
                  ],
                );
              },
            ),
          ]);
        },
      ),
      Sheet(
        child: BucketForm(bucket: _sheetBucket),
        isOpen: bucketSheetOpen,
        onClose: () => setState(() {
          bucketSheetOpen = false;
          _sheetBucket = null;
        }),
      ),
    ]);
  }
}
