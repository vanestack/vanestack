import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class DataTable<T> extends StatefulComponent {
  final List<DataColumn<T>> columns;
  final List<T> data;
  final void Function(T)? onRowClick;

  DataTable({
    super.key,
    required this.columns,
    required this.data,
    this.onRowClick,
  });
  @override
  State<StatefulComponent> createState() => _DataTableState<T>();
}

class _DataTableState<T> extends State<DataTable<T>> {
  @override
  Component build(BuildContext context) {
    return table(classes: 'table table-auto', [
      thead(classes: 'sticky top-0 z-10 bg-muted border-b border-border', [
        tr(classes: 'divide-x divide-border', [
          for (var column in component.columns)
            th(
              classes: 'text-left hover:bg-accent transition-colors px-4 py-2',
              [column.label],
            ),
        ]),
      ]),
      tbody([
        for (var item in component.data)
          tr(
            key: ValueKey(item),
            events: events(
              onClick: component.onRowClick != null ? () => component.onRowClick!(item) : null,
            ),
            classes:
                'divide-x divide-border border-b border-border transition-colors px-4 py-2 ${component.onRowClick != null ? 'cursor-pointer' : ''}',
            [
              for (var column in component.columns) td(classes: 'hover:bg-accent', [column.builder(item)]),
            ],
          ),
      ]),
    ]);
  }
}

class DataColumn<T> {
  final Component label;
  final Component Function(T) builder;

  DataColumn({required this.label, required this.builder});
}
