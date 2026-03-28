import 'package:vanestack_client/vanestack_client.dart';
import 'package:vanestack_dashboard/components/menu_button.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/dom.dart' hide Filter;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/log_details.dart';
import '../components/refresh_icon_button.dart';
import '../components/sheet.dart';
import '../providers/client.dart';

class LogsPage extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  bool _sheetOpen = false;
  AppLog? _sheetLog;

  int _page = 0;
  int? _count;
  int _rowsPerPage = 10;

  List<AppLog> _logs = [];

  // Filters
  LogSource? _selectedSource;
  final Set<LogLevel> _selectedLevels = {};

  final date = DateFormat.yMEd().add_Hm();

  Future<void> _getLogs({int page = 0}) async {
    final client = context.read(clientProvider);

    final filters = <Filter>[];

    if (_selectedSource != null) {
      filters.add(Filter.where('source', isEqualTo: _selectedSource!.name));
    }

    if (_selectedLevels.isNotEmpty) {
      filters.add(
        Filter.or([
          for (final level in _selectedLevels) Filter.where('level', isEqualTo: level.name),
        ]),
      );
    }

    final filter = filters.isEmpty ? null : Filter.and(filters);

    final result = await client.logs.list(
      filter: filter?.build(),
      orderBy: OrderBy.desc('created_at').build(),
      limit: _rowsPerPage,
      offset: page * _rowsPerPage,
    );

    setState(() {
      _logs = result.logs;
      _count = result.count;
      _page = page;
    });
  }

  void _loadPrevious() {
    if (_page == 0) return;
    _getLogs(page: _page - 1);
  }

  void _loadNext() {
    if (_count != null && (_page + 1) * _rowsPerPage >= _count!) return;
    _getLogs(page: _page + 1);
  }

  void _loadFirst() {
    _getLogs();
  }

  void _loadLast() {
    if (_count == null) return;
    final lastPage = (_count! / _rowsPerPage).ceil() - 1;
    _getLogs(page: lastPage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getLogs();
  }

  List<String> getPagination(int currentPage, int totalCount, int perPage) {
    int totalPages = (totalCount / perPage).ceil();

    if (totalPages <= 1) return ["1"];
    if (totalPages == 2) return ["1", "2"];

    List<int> items = [];

    if (currentPage <= 2) {
      items = [1, 2, 3];
    } else if (currentPage >= totalPages - 1) {
      items = [totalPages - 2, totalPages - 1, totalPages];
    } else {
      items = [currentPage - 1, currentPage, currentPage + 1];
    }

    return items.map((e) => e.toString()).toList();
  }

  String _levelBadgeClass(LogLevel level) {
    return switch (level) {
      LogLevel.debug || LogLevel.none => 'badge-secondary',
      LogLevel.info => 'badge-outline text-blue-600 border-blue-200',
      LogLevel.warn => 'badge-outline text-yellow-600 border-yellow-200',
      LogLevel.error => 'badge-outline text-destructive border-red-200',
    };
  }

  String _sourceBadgeClass() {
    return 'badge-secondary';
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col flex-1 h-full overflow-hidden', [
      // Header with filters
      div(
        classes:
            'bg-card border-b border-border shrink-0 px-4 py-3 md:py-0 md:min-h-16 flex flex-col md:flex-row md:items-center md:justify-between gap-3',
        [
          div(classes: 'flex items-center', [
            MenuButton(classes: 'md:hidden mr-2'),
            h2(classes: 'text-2xl font-semibold', [Component.text('Logs')]),
          ]),
          div(classes: 'flex gap-3 items-center flex-wrap', [
            // Source filter dropdown
            div(classes: 'flex items-center gap-2', [
              span(classes: 'text-sm text-muted-foreground hidden sm:inline', [Component.text('Source')]),
              select(
                classes: 'select text-sm h-9 w-32',
                value: _selectedSource?.name ?? 'all',
                onChange: (values) {
                  setState(() {
                    _selectedSource = values.first == 'all'
                        ? null
                        : LogSource.values.firstWhere((e) => e.name == values.first);
                  });
                  _getLogs();
                },
                [
                  option([], value: 'all', label: 'All'),
                  for (var source in LogSource.values)
                    option([], value: source.name, label: source.name[0].toUpperCase() + source.name.substring(1)),
                ],
              ),
            ]),
            // Level filter buttons
            div(classes: 'flex items-center gap-1', [
              for (var level in LogLevel.values)
                button(
                  type: ButtonType.button,
                  classes:
                      'text-xs px-2 py-1 rounded-md border transition-colors ${_selectedLevels.contains(level) ? _activeLevelClass(level) : 'border-border text-muted-foreground hover:bg-accent'}',
                  onClick: () {
                    setState(() {
                      if (_selectedLevels.contains(level)) {
                        _selectedLevels.remove(level);
                      } else {
                        _selectedLevels.add(level);
                      }
                    });
                    _getLogs();
                  },
                  [Component.text(level.name.toUpperCase())],
                ),
            ]),
            // Rows per page selector
            div(classes: 'flex items-center gap-2', [
              span(classes: 'text-sm text-muted-foreground hidden sm:inline', [Component.text('Show')]),
              select(
                classes: 'select text-sm h-9 w-20',
                value: _rowsPerPage.toString(),
                onChange: (values) {
                  setState(() {
                    _rowsPerPage = int.parse(values.first);
                  });
                  _getLogs();
                },
                [
                  optgroup(
                    label: 'Rows per page',
                    [
                      for (var size in [10, 20, 50, 100]) option([], value: size.toString(), label: size.toString()),
                    ],
                  ),
                ],
              ),
            ]),
            // Refresh button
            RefreshIconButton(onClick: () => _getLogs(page: _page)),
          ]),
        ],
      ),

      // Table
      div(classes: "flex-1 h-full overflow-x-auto", [
        table(classes: 'table table-auto', [
          colgroup([
            col(classes: 'w-auto'),
            col(classes: 'w-auto'),
            col(classes: 'w-auto'),
            col(classes: 'w-full'),
          ]),
          tbody([
            for (var log in _logs)
              tr(
                classes: 'cursor-pointer hover:bg-accent',
                events: events(
                  onClick: () => setState(() {
                    _sheetLog = log;
                    _sheetOpen = true;
                  }),
                ),
                [
                  td([Component.text(date.format(log.createdAt))]),
                  td([
                    span(classes: _levelBadgeClass(log.level), [
                      Component.text(log.level.name.toUpperCase()),
                    ]),
                  ]),
                  td([
                    span(classes: _sourceBadgeClass(), [
                      Component.text(log.sourceName[0].toUpperCase() + log.sourceName.substring(1)),
                    ]),
                  ]),
                  td(
                    classes: "whitespace-nowrap overflow-hidden text-ellipsis",
                    [Component.text(log.message)],
                  ),
                ],
              ),
          ]),
        ]),
      ]),

      // Pagination
      div(
        classes:
            'h-12 bg-card shrink-0 border-t border-border flex items-center justify-evenly md:justify-between px-4',
        attributes: {'role': 'navigation', 'aria-label': 'pagination'},
        [
          ul(classes: 'flex flex-row items-center gap-1', [
            li(key: ValueKey('first'), [
              button(classes: 'btn-icon-ghost', onClick: _loadFirst, [
                i(classes: 'icon-chevron-first', []),
              ]),
            ]),
            li(key: ValueKey('prev_${_page - 1}'), [
              button(classes: 'btn-icon-ghost', onClick: _loadPrevious, [
                i(classes: 'icon-chevron-left', []),
              ]),
            ]),
            for (var item in getPagination(
              _page + 1,
              _count ?? 0,
              _rowsPerPage,
            ))
              li(key: ValueKey(item), [
                button(
                  classes: 'btn-${'${_page + 1}' == item ? 'outline' : 'ghost'}',
                  onClick: () => _getLogs(page: int.tryParse(item)! - 1),
                  [Component.text(item)],
                ),
              ]),
            li(key: ValueKey('next_${_page + 1}'), [
              button(classes: 'btn-icon-ghost', onClick: _loadNext, [
                i(classes: 'icon-chevron-right', []),
              ]),
            ]),
            li(key: ValueKey('last_${((_count ?? 0) + _rowsPerPage - 1) ~/ _rowsPerPage - 1}'), [
              button(classes: 'btn-icon-ghost', onClick: _loadLast, [
                i(classes: 'icon-chevron-last', []),
              ]),
            ]),
          ]),
          span(classes: 'hidden md:inline text-sm text-muted-foreground whitespace-nowrap', [
            Component.text('${_count ?? 0} Records Found'),
          ]),
        ],
      ),

      Sheet(
        isOpen: _sheetOpen,
        onClose: () => setState(() => _sheetOpen = false),
        child: LogDetails(log: _sheetLog),
      ),
    ]);
  }

  String _activeLevelClass(LogLevel level) {
    return switch (level) {
      LogLevel.debug || LogLevel.none => 'border-gray-400 bg-gray-100 text-gray-700',
      LogLevel.info => 'border-blue-400 bg-blue-50 text-blue-700',
      LogLevel.warn => 'border-yellow-400 bg-yellow-50 text-yellow-700',
      LogLevel.error => 'border-red-400 bg-red-50 text-red-700',
    };
  }
}
