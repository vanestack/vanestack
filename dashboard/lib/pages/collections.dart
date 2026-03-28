import 'package:collection/collection.dart';
import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' hide Document;
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:universal_web/web.dart' hide Document;

import '../components/alert_dialog.dart';
import '../components/collection_form.dart';
import '../components/collection_menu_item.dart';
import '../components/collection_table.dart';
import '../components/document_form.dart';
import '../components/empty.dart';
import '../components/menu_button.dart';
import '../components/progress_indicator.dart';
import '../components/refresh_icon_button.dart';
import '../components/sheet.dart';
import '../providers/client.dart';
import '../providers/collections.dart';
import '../providers/documents.dart';
import '../utils/toast.dart';

class CollectionsPage extends StatefulComponent {
  final String? selectedCollection;

  const CollectionsPage({super.key, this.selectedCollection});

  @override
  State<StatefulComponent> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  static const String _generateDialogId = 'generate-dialog';

  bool collectionSheetOpen = false;
  bool documentSheetOpen = false;
  bool mobileSidebarOpen = false;
  Collection? _sheetCollection;
  Document? _sheetDocument;
  int _generateCount = 10;

  void _openGenerateDialog() {
    _generateCount = 10;
    Future.microtask(() {
      final modal = document.getElementById(_generateDialogId) as HTMLDialogElement?;
      modal?.showModal();
    });
  }

  Future<bool> _generateDocuments() async {
    final collectionName = component.selectedCollection;
    if (collectionName == null) return false;

    final client = context.read(clientProvider);
    final result = await client.collections.generate(
      collectionName: collectionName,
      count: _generateCount,
    );
    context.invalidate(documentsProvider);
    showToast(
      category: ToastCategory.success,
      title: 'Documents generated',
      description: 'Successfully generated ${result.count} documents.',
    );
    return true;
  }

  @override
  Component build(BuildContext context) {
    final collections = context.watch(collectionsProvider);
    return Component.fragment([
      collections.when(
        error: (e, stackTrace) => Component.empty(),
        loading: () => div(classes: 'h-full flex items-center justify-center', [
          ProgressIndicator(),
        ]),
        data: (collections) {
          // Auto-select first collection if none selected
          if (collections.isNotEmpty && component.selectedCollection == null) {
            Future.microtask(() {
              Router.of(context).push('/_/collections/${collections.first.name}');
            });
            return div(classes: 'h-full flex items-center justify-center', [
              ProgressIndicator(),
            ]);
          }

          if (collections.isEmpty) {
            return div(classes: 'h-full flex flex-col', [
              // Mobile appbar
              div(
                classes: 'md:hidden h-16 bg-card border-b border-border shrink-0 px-4 flex items-center',
                [
                  MenuButton(),
                  h1(
                    classes: 'text-2xl font-semibold ml-2',
                    [Component.text('Collections')],
                  ),
                ],
              ),
              div(classes: 'flex-1 flex items-center justify-center', [
                Empty(
                  icon: 'folder',
                  title: 'No Collections',
                  description: 'Get started by creating your first collection.',
                  button: button(
                    classes: 'btn',
                    [
                      i([], classes: 'icon-plus'),
                      Component.text('Create Collection'),
                    ],
                    onClick: () => setState(() {
                      _sheetCollection = null;
                      collectionSheetOpen = true;
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
                      Component.text('Collections'),
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
                  for (final collection in collections)
                    div(
                      events: events(onClick: () => setState(() => mobileSidebarOpen = false)),
                      [
                        CollectionMenuItem(
                          label: collection.name,
                          icon: collection is ViewCollection ? 'eye' : 'folder',
                          active: collection.name == component.selectedCollection,
                          to: '/_/collections/${collection.name}',
                        ),
                      ],
                    ),
                  button(
                    [
                      i([], classes: 'icon-plus'),
                      Component.text('New Collection'),
                    ],
                    classes: 'w-full btn-ghost mt-1',
                    onClick: () => setState(() {
                      _sheetCollection = null;
                      collectionSheetOpen = true;
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
                  for (final collection in collections)
                    CollectionMenuItem(
                      label: collection.name,
                      icon: collection is ViewCollection ? 'eye' : 'folder',
                      active: collection.name == component.selectedCollection,
                      to: '/_/collections/${collection.name}',
                    ),
                  button(
                    [
                      i([], classes: 'icon-plus'),
                      Component.text('New Collection'),
                    ],
                    classes: 'w-full btn-ghost mt-1',
                    onClick: () => setState(() {
                      _sheetCollection = null;
                      collectionSheetOpen = true;
                    }),
                  ),
                ]),
              ],
            ),
            Builder(
              builder: (context) {
                final collection = collections.firstWhereOrNull(
                  (c) => c.name == component.selectedCollection,
                );

                if (collection == null) {
                  return div(classes: 'flex-1 flex flex-col', [
                    // Mobile appbar
                    div(
                      classes: 'md:hidden h-16 bg-card border-b border-border shrink-0 px-4 flex items-center',
                      [
                        MenuButton(),
                        h1(
                          classes: 'text-2xl font-semibold ml-2',
                          [Component.text('Collections')],
                        ),
                      ],
                    ),
                    Empty(
                      icon: 'mouse-pointer-click',
                      title: 'Select a collection',
                      description: 'Please select a collection from the list.',
                      button: button(
                        classes: 'btn md:hidden',
                        events: events(onClick: () => setState(() => mobileSidebarOpen = true)),
                        [
                          Component.text('Select Collection'),
                        ],
                      ),
                    ),
                  ]);
                }

                return div(
                  classes: "flex flex-col flex-1 h-full overflow-hidden",
                  [
                    // Header - responsive
                    div(
                      classes:
                          'bg-card border-b border-border shrink-0 px-4 py-3 md:py-0 md:h-16 flex flex-col md:flex-row md:items-center justify-between gap-3',
                      [
                        // Title row with mobile menu button
                        div(classes: 'flex items-center gap-2 min-w-0 flex-1', [
                          // Mobile: burger menu
                          MenuButton(classes: 'md:hidden shrink-0'),
                          // Mobile: collection name with chevron to open sidebar
                          button(
                            classes:
                                'md:hidden flex items-center gap-1 hover:bg-accent rounded-md px-2 py-1 shrink-0',
                            events: events(onClick: () => setState(() => mobileSidebarOpen = true)),
                            [
                              span(classes: 'text-xl font-semibold', [
                                Component.text(collection.name),
                              ]),
                              i(classes: 'icon-chevron-down text-muted-foreground', []),
                            ],
                          ),
                          // Desktop: just the title
                          h2([
                            Component.text(collection.name),
                          ], classes: 'hidden md:block text-2xl font-semibold'),
                        ]),
                        // Action buttons
                        div(classes: 'flex items-center gap-2 flex-wrap', [
                          RefreshIconButton(
                            key: ValueKey(collection.name),
                            onClick: () async {
                              context.invalidate(documentsProvider);
                              await context.read(
                                documentsProvider(collection.name).future,
                              );
                            },
                          ),
                          // Hide generate button for view collections
                          if (collection is! ViewCollection)
                            button(
                              classes: 'btn-icon-outline flex-1 md:flex-none',
                              [
                                i([], classes: 'icon-sparkles'),
                              ],
                              onClick: _openGenerateDialog,
                            ),
                          // Hide new document button for view collections
                          if (collection is! ViewCollection)
                            button(
                              classes: 'btn-outline flex-1 md:flex-none',
                              [
                                i([], classes: 'icon-plus'),
                                Component.text('New Document'),
                              ],
                              onClick: () => setState(() {
                                _sheetDocument = null;
                                documentSheetOpen = true;
                              }),
                            ),
                          button(
                            key: ValueKey(collection.name),
                            classes: 'btn flex-1 md:flex-none',
                            [
                              i([], classes: 'icon-pencil'),
                              Component.text('Edit'),
                            ],
                            onClick: () => setState(() {
                              _sheetCollection = collection;
                              collectionSheetOpen = true;
                            }),
                          ),
                        ]),
                      ],
                    ),
                    CollectionTable(
                      collection: collection,
                      openDocumentForm: (document) => setState(() {
                        _sheetDocument = document;
                        documentSheetOpen = true;
                      }),
                    ),
                    Sheet(
                      child: DocumentForm(
                        key: ValueKey(collection.toJsonString() + (_sheetDocument?.id ?? 'new')),
                        collection: collection,
                        document: _sheetDocument,
                      ),
                      isOpen: documentSheetOpen,
                      onClose: () => setState(() {
                        documentSheetOpen = false;
                        _sheetDocument = null;
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
        child: CollectionForm(
          key: ValueKey(_sheetCollection?.toJsonString() ?? 'new'),
          collection: _sheetCollection,
        ),
        isOpen: collectionSheetOpen,
        onClose: () => setState(() {
          collectionSheetOpen = false;
          _sheetCollection = null;
        }),
      ),
      if (component.selectedCollection != null)
        AlertDialog(
          key: ValueKey(component.selectedCollection),
          id: _generateDialogId,
          title: Component.text('Generate Sample Data'),
          description: Component.text('Generate fake documents for testing purposes.'),
          content: div(classes: 'space-y-2', [
            label(classes: 'text-sm font-medium text-foreground', [
              Component.text('Number of documents'),
            ]),
            input<int>(
              type: InputType.number,
              classes: 'input w-full',
              attributes: {'min': '1', 'max': '1000'},
              value: _generateCount.toString(),
              onInput: (value) => _generateCount = value,
            ),
            p(classes: 'text-xs text-muted-foreground', [
              Component.text('Enter a value between 1 and 1000'),
            ]),
          ]),
          button: (saving) => Component.fragment([
            if (saving) i(classes: 'icon-loader-2 animate-spin', []),
            Component.text(saving ? 'Generating...' : 'Generate'),
          ]),
          onSubmit: _generateDocuments,
        ),
    ]);
  }
}
