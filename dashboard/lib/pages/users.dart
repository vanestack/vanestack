import 'package:vanestack_client/vanestack_client.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/data_table.dart';
import '../components/empty.dart';
import '../components/menu_button.dart';
import '../components/progress_indicator.dart';
import '../components/refresh_icon_button.dart';
import '../components/sheet.dart';
import '../components/sort_icon.dart';
import '../components/user_form.dart';
import '../providers/users.dart';

class UsersPage extends StatefulComponent {
  const UsersPage({super.key});

  @override
  State<StatefulComponent> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _date = DateFormat.yMd().add_Hms();
  bool _sheetOpen = false;
  User? _sheetUser;

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

  void setPage(int page) => context.read(usersPageProvider.notifier).set(page);

  void sort(String column) {
    final value = context.read(usersOrderProvider);
    context.read(usersOrderProvider.notifier).set((
      column,
      value.$1 == column
          ? value.$2 == SortDirection.desc
                ? SortDirection.asc
                : SortDirection.desc
          : value.$2,
    ));
  }

  @override
  Component build(BuildContext context) {
    final page = context.watch(usersPageProvider);
    final rowsPerPage = context.watch(usersRowsPerPageProvider);
    final (sortColumn, sortDirection) = context.watch(usersOrderProvider);

    return div(classes: 'h-full', [
      context
          .watch(usersProvider)
          .when(
            skipLoadingOnReload: true,
            error: (e, stackTrace) => Component.empty(),
            loading: () => div(
              classes: 'h-full flex items-center justify-center',
              [const ProgressIndicator()],
            ),
            data: (result) {
              if (result.users.isEmpty) {
                return Component.wrapElement(
                  classes: 'h-full',
                  child: Empty(
                    icon: 'users',
                    title: 'No Users',
                    description: 'Get started by creating your first user.',
                    button: button(classes: 'btn', [
                      i([], classes: 'icon-plus'),
                      Component.text('Create User'),
                    ], onClick: () => setState(() => _sheetOpen = true)),
                  ),
                );
              }

              return div(classes: "flex flex-col flex-1 h-full overflow-hidden", [
                // Header - responsive
                div(
                  classes:
                      'bg-card border-b border-border shrink-0 px-4 py-3 md:py-0 md:h-16 flex flex-row md:items-center justify-between gap-3',
                  [
                    div(
                      classes: 'flex items-center grow',
                      [
                        MenuButton(
                          classes: 'md:hidden mr-2',
                        ),
                        h2([Component.text('Users')], classes: 'text-xl md:text-2xl font-semibold'),
                      ],
                    ),
                    // Action buttons
                    div(classes: 'flex items-center gap-2', [
                      RefreshIconButton(
                        onClick: () async {
                          context.invalidate(usersProvider);
                          await context.read(usersProvider.future);
                        },
                      ),
                      button(
                        classes: 'btn-icon md:hidden',
                        [
                          i([], classes: 'icon-plus'),
                        ],
                        onClick: () => setState(() => _sheetOpen = true),
                      ),
                      button(
                        classes: 'btn hidden md:inline-flex',
                        [
                          i([], classes: 'icon-plus'),
                          Component.text('Create User'),
                        ],
                        onClick: () => setState(() => _sheetOpen = true),
                      ),
                    ]),
                  ],
                ),
                div(classes: 'flex-1 h-full overflow-x-auto', [
                  DataTable<User>(
                    onRowClick: (user) => setState(() {
                      _sheetUser = user;
                      _sheetOpen = true;
                    }),
                    columns: [
                      DataColumn(
                        label: div(
                          events: events(onClick: () => sort('id')),
                          classes: 'flex items-center gap-2 cursor-pointer',
                          [
                            i([], classes: 'icon-key'),
                            Component.text('ID'),
                            SortIcon(
                              show: sortColumn == 'id',
                              direction: sortDirection,
                            ),
                          ],
                        ),
                        builder: (user) => Component.text(user.id),
                      ),
                      DataColumn(
                        label: div(
                          events: events(onClick: () => sort('email')),
                          classes: 'flex items-center gap-2 cursor-pointer',
                          [
                            i([], classes: 'icon-mail'),
                            Component.text('Email'),
                            SortIcon(
                              show: sortColumn == 'email',
                              direction: sortDirection,
                            ),
                          ],
                        ),
                        builder: (user) => Component.text(user.email),
                      ),
                      DataColumn(
                        label: div(
                          classes: 'flex items-center gap-2',
                          [
                            i([], classes: 'icon-link'),
                            Component.text('Providers'),
                          ],
                        ),
                        builder: (user) => div(
                          classes: 'flex items-center gap-1.5',
                          [
                            for (final provider in user.providers)
                              if (provider == 'email')
                                i(classes: 'icon-mail w-4 h-4 opacity-60', [])
                              else
                                img(
                                  classes: 'w-4 h-4 opacity-60',
                                  src:
                                      'https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/${provider.toLowerCase()}.svg',
                                ),
                          ],
                        ),
                      ),
                      DataColumn(
                        label: div(
                          events: events(onClick: () => sort('name')),
                          classes: 'flex items-center gap-2 cursor-pointer',
                          [
                            i([], classes: 'icon-user'),
                            Component.text('Name'),
                            SortIcon(
                              show: sortColumn == 'name',
                              direction: sortDirection,
                            ),
                          ],
                        ),
                        builder: (user) => Component.text(user.name ?? ''),
                      ),
                      DataColumn(
                        label: div(
                          events: events(onClick: () => sort('created_at')),
                          classes: 'flex items-center gap-2 cursor-pointer',
                          [
                            i([], classes: 'icon-calendar'),
                            Component.text('Created At'),
                            SortIcon(
                              show: sortColumn == 'created_at',
                              direction: sortDirection,
                            ),
                          ],
                        ),
                        builder: (user) => Component.text(_date.format(user.createdAt)),
                      ),
                      DataColumn(
                        label: div(
                          events: events(onClick: () => sort('updated_at')),
                          classes: 'flex items-center gap-2 cursor-pointer',
                          [
                            i([], classes: 'icon-calendar'),
                            Component.text('Updated At'),
                            SortIcon(
                              show: sortColumn == 'updated_at',
                              direction: sortDirection,
                            ),
                          ],
                        ),
                        builder: (user) => Component.text(_date.format(user.updatedAt)),
                      ),
                    ],
                    data: result.users,
                  ),
                ]),
                // Pagination footer - responsive
                div(
                  classes:
                      'bg-card shrink-0 border-t border-border flex items-center justify-evenly md:justify-between px-4 py-2 md:h-12',
                  [
                    ul(classes: 'flex flex-row items-center gap-0.5 md:gap-1', [
                      li(key: ValueKey('first'), [
                        button(
                          classes: 'btn-icon-ghost',
                          onClick: () => setPage(0),
                          [i(classes: 'icon-chevron-first', [])],
                        ),
                      ]),
                      li(key: ValueKey('prev_${page - 1}'), [
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
                        '${result.count} ${result.count == 1 ? 'user' : 'users'}',
                      ),
                    ]),
                  ],
                ),
              ]);
            },
          ),
      Sheet(
        child: UserForm(user: _sheetUser),
        isOpen: _sheetOpen,
        onClose: () => setState(() {
          _sheetOpen = false;
          _sheetUser = null;
        }),
      ),
    ]);
  }
}
