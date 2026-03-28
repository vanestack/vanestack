import 'package:vanestack_client/vanestack_client.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' hide Document;
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../providers/documents.dart';
import 'data_table.dart';
import 'empty.dart';
import 'progress_indicator.dart';
import 'sort_icon.dart';

class CollectionTable extends StatefulComponent {
  final Collection collection;
  final void Function(Document?) openDocumentForm;

  const CollectionTable({
    super.key,
    required this.collection,
    required this.openDocumentForm,
  });

  @override
  CollectionTableState createState() => CollectionTableState();
}

class CollectionTableState extends State<CollectionTable> {
  final _date = DateFormat.yMd().add_Hms();
  List<String> getPagination(int currentPage, int totalCount, int perPage) {
    int totalPages = (totalCount / perPage).ceil();

    if (totalPages <= 1) return ["1"];
    if (totalPages == 2) return ["1", "2"];

    List<int> items = [];

    // CASE 1: At the beginning → 1,2,3
    if (currentPage <= 2) {
      items = [1, 2, 3];
    }
    // CASE 2: At the end → (n-2, n-1, n)
    else if (currentPage >= totalPages - 1) {
      items = [totalPages - 2, totalPages - 1, totalPages];
    }
    // CASE 3: Middle → (current-1, current, current+1)
    else {
      items = [currentPage - 1, currentPage, currentPage + 1];
    }

    return items.map((e) => e.toString()).toList();
  }

  void setPage(int page) {
    context.read(documentsPageProvider(component.collection.name).notifier).set(page);
  }

  void sort(String column) {
    final value = context.read(documentsOrderProvider(component.collection.name));
    context.read(documentsOrderProvider(component.collection.name).notifier).set((
      column,
      value.$1 == column
          ? value.$2 == SortDirection.desc
                ? SortDirection.asc
                : SortDirection.desc
          : value.$2,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.invalidate(documentsOrderProvider);
  }

  @override
  Component build(BuildContext context) {
    final page = context.watch(documentsPageProvider(component.collection.name));
    final rowsPerPage = context.watch(documentsRowsPerPageProvider(component.collection.name));
    final (sortColumn, sortDirection) = context.watch(documentsOrderProvider(component.collection.name));
    return context
        .watch(documentsProvider(component.collection.name))
        .when(
          skipLoadingOnReload: true,
          error: (e, stackTrace) => Component.empty(),
          loading: () => div(
            classes: 'h-full flex items-center justify-center',
            [const ProgressIndicator()],
          ),
          data: (result) {
            if (result.documents.isEmpty) {
              return Component.wrapElement(
                classes: 'h-full',
                child: Empty(
                  icon: 'folder',
                  title: 'No Documents',
                  description: component.collection is ViewCollection
                      ? 'This view has no documents.'
                      : 'Get started by creating your first document.',
                  button: component.collection is ViewCollection
                      ? null
                      : button(classes: 'btn', [
                          i([], classes: 'icon-plus'),
                          Component.text('Create Document'),
                        ], onClick: () => component.openDocumentForm(null)),
                ),
              );
            }
            return Component.fragment([
              div(classes: 'flex-1 h-full overflow-x-auto', [
                DataTable<Document>(
                  onRowClick: component.openDocumentForm,
                  columns: [
                    ...component.collection.attributes.map(
                      (column) => DataColumn(
                        label: div(
                          events: events(onClick: () => sort(column.name)),
                          classes: 'flex items-center gap-2 cursor-pointer',
                          [
                            i(
                              [],
                              classes: switch (column) {
                                Attribute(:final primaryKey) when primaryKey => 'icon-key',
                                TextAttribute() => 'icon-type',
                                IntAttribute() || DoubleAttribute() => 'icon-sigma',
                                BoolAttribute() => 'icon-square-check',
                                DateAttribute() => 'icon-calendar',
                                JsonAttribute() => 'icon-braces',
                              },
                            ),
                            Component.text(column.name),
                            SortIcon(
                              show: sortColumn == column.name,
                              direction: sortDirection,
                            ),
                          ],
                        ),
                        builder: (item) => Component.text(switch (column.name) {
                          'id' => item.id,
                          'created_at' => item.createdAt != null ? _date.format(item.createdAt!) : '-',
                          'updated_at' => item.updatedAt != null ? _date.format(item.updatedAt!) : '-',
                          _ => switch (column) {
                            DateAttribute() => switch (item.data[column.name]) {
                              int value => _date.format(DateTime.fromMillisecondsSinceEpoch(value * 1000)),
                              _ => '',
                            },
                            _ => item.data[column.name]?.toString() ?? '',
                          },
                        }),
                      ),
                    ),
                  ],
                  data: result.documents,
                ),
              ]),
              div(
                classes:
                    'h-12 w-full bg-card shrink-0 border-t border-border flex items-center justify-evenly md:justify-between px-4',
                [
                  ul(classes: 'flex flex-row items-center gap-1', [
                    li([
                      button(
                        classes: 'btn-icon-ghost',
                        onClick: () => setPage(0),
                        [i(classes: 'icon-chevron-first', [])],
                      ),
                    ]),
                    li(key: ValueKey('key${page - 1}'), [
                      button(
                        classes: 'btn-icon-ghost',
                        onClick: () {
                          if (page == 0) return;
                          setPage(page - 1);
                        },
                        [i(classes: 'icon-chevron-left', [])],
                      ),
                    ]),
                    for (var item in getPagination(
                      page + 1,
                      result.count,
                      rowsPerPage,
                    ))
                      li(key: ValueKey(item), [
                        button(
                          classes: 'btn-${'${page + 1}' == item ? 'outline' : 'ghost'}',
                          onClick: () => setPage(int.parse(item) - 1),
                          [Component.text(item)],
                        ),
                      ]),
                    li(key: ValueKey('next_${page + 1}'), [
                      button(
                        classes: 'btn-icon-ghost',
                        onClick: () {
                          if ((page + 1) * rowsPerPage >= result.count) {
                            return;
                          }

                          setPage(page + 1);
                        },
                        [i(classes: 'icon-chevron-right', [])],
                      ),
                    ]),
                    li(key: ValueKey('last_${((result.count + rowsPerPage - 1) ~/ rowsPerPage) - 1}'), [
                      button(
                        classes: 'btn-icon-ghost',
                        onClick: () {
                          if (result.count == 0) return;
                          final lastPage = ((result.count + rowsPerPage - 1) ~/ rowsPerPage) - 1;
                          setPage(lastPage);
                        },
                        [i(classes: 'icon-chevron-last', [])],
                      ),
                    ]),
                  ]),
                  span(classes: 'hidden md:inline text-sm text-muted-foreground', [
                    Component.text(
                      '${result.count} ${result.count == 1 ? 'document' : 'documents'}',
                    ),
                  ]),
                ],
              ),
            ]);
          },
        );
  }
}
