import 'package:vanestack_client/vanestack_client.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../components/data_table.dart';
import '../components/error_alert.dart';
import '../components/progress_indicator.dart';
import '../components/sheet.dart';
import '../components/superuser_form.dart';
import '../providers/superusers.dart';

class SuperusersSettingsPage extends StatefulComponent {
  const SuperusersSettingsPage({super.key});

  @override
  State<StatefulComponent> createState() => _SuperusersSettingsPageState();
}

class _SuperusersSettingsPageState extends State<SuperusersSettingsPage> {
  final _date = DateFormat.yMd().add_Hms();
  bool _sheetOpen = false;
  User? _sheetUser;

  @override
  Component build(BuildContext context) {
    final superusersAsync = context.watch(superusersProvider);

    return div(classes: 'space-y-6', [
      // Header
      div(classes: 'flex items-center justify-between', [
        div([
          h2(classes: 'text-lg font-semibold', [Component.text('Superusers')]),
          p(classes: 'text-sm text-muted-foreground', [
            Component.text('Manage administrator accounts with full system access.'),
          ]),
        ]),
        button(
          classes: 'btn',
          events: events(
            onClick: () => setState(() {
              _sheetUser = null;
              _sheetOpen = true;
            }),
          ),
          [i(classes: 'icon-plus', []), Component.text('Add Superuser')],
        ),
      ]),

      // Table
      superusersAsync.when(
        skipLoadingOnReload: true,
        loading: () => div(classes: 'flex justify-center py-12', [
          const ProgressIndicator(),
        ]),
        error: (e, _) => ErrorAlert(title: 'Failed to load superusers'),
        data: (result) {
          if (result.users.isEmpty) {
            return div(
              classes: 'text-center py-12 border border-dashed border-border rounded-lg',
              [
                i(classes: 'icon-shield text-4xl text-muted-foreground mb-4', []),
                p(classes: 'text-muted-foreground', [Component.text('No superusers found.')]),
                p(classes: 'text-sm text-muted-foreground', [
                  Component.text('Add a superuser to grant full system access.'),
                ]),
              ],
            );
          }

          return div(classes: 'border border-border rounded-md overflow-hidden', [
            DataTable<User>(
              onRowClick: (user) => setState(() {
                _sheetUser = user;
                _sheetOpen = true;
              }),
              columns: [
                DataColumn(
                  label: div(classes: 'flex items-center gap-2', [
                    i(classes: 'icon-mail', []),
                    Component.text('Email'),
                  ]),
                  builder: (user) => Component.text(user.email),
                ),
                DataColumn(
                  label: div(classes: 'flex items-center gap-2', [
                    i(classes: 'icon-user', []),
                    Component.text('Name'),
                  ]),
                  builder: (user) => Component.text(user.name ?? '-'),
                ),
                DataColumn(
                  label: div(classes: 'flex items-center gap-2', [
                    i(classes: 'icon-calendar', []),
                    Component.text('Created'),
                  ]),
                  builder: (user) => Component.text(_date.format(user.createdAt)),
                ),
              ],
              data: result.users,
            ),
          ]);
        },
      ),

      // Sheet for form
      Sheet(
        child: SuperuserForm(user: _sheetUser),
        isOpen: _sheetOpen,
        onClose: () => setState(() {
          _sheetOpen = false;
          _sheetUser = null;
        }),
      ),
    ]);
  }
}
