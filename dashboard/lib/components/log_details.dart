import 'package:vanestack_client/vanestack_client.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'sheet.dart';

class LogDetails extends StatelessComponent {
  final AppLog? log;

  const LogDetails({this.log, super.key});

  static final _date = DateFormat.yMEd().add_Hm();

  String _levelBadgeClass(LogLevel level) {
    return switch (level) {
      LogLevel.debug || LogLevel.none => 'badge-secondary',
      LogLevel.info => 'badge-outline text-blue-600 border-blue-200',
      LogLevel.warn => 'badge-outline text-yellow-600 border-yellow-200',
      LogLevel.error => 'badge-outline text-destructive border-red-200',
    };
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col h-full', [
      // HEADER
      div(classes: 'px-6 py-4 border-b bg-muted flex justify-between items-center', [
        h2(classes: 'text-lg font-bold', [Component.text('Log Details')]),
        button(
          classes: 'btn-icon-ghost',
          events: events(onClick: () => Sheet.of(context)?.close()),
          [i(classes: 'icon-x', [])],
        ),
      ]),

      // CONTENT
      div(classes: 'p-6 space-y-4 flex-1 overflow-y-auto', [
        _logItem('Timestamp', span([Component.text(_date.format(log?.createdAt ?? DateTime.now()))])),
        _logItem(
          'Level',
          span(
            classes: log != null ? _levelBadgeClass(log!.level) : '',
            [Component.text(log?.level.name.toUpperCase() ?? '-')],
          ),
        ),
        _logItem(
          'Source',
          span(classes: 'badge-secondary', [
            Component.text(log != null ? log!.sourceName[0].toUpperCase() + log!.sourceName.substring(1) : '-'),
          ]),
        ),
        _logItem('Message', span([Component.text(log?.message ?? '-')])),
        if (log?.userId != null && log!.userId!.isNotEmpty)
          _logItem('User ID', span(classes: 'font-mono text-xs', [Component.text(log!.userId!)])),
        if (log?.context != null && log!.context!.isNotEmpty)
          _logItem('Context', span(classes: 'text-muted-foreground', [Component.text(log!.context!)])),
        if (log?.error != null && log!.error!.isNotEmpty)
          _logItem(
            'Error',
            pre(classes: 'text-sm text-destructive bg-destructive/10 p-3 rounded-md overflow-x-auto', [
              Component.text(log!.error!),
            ]),
          ),
        if (log?.stackTrace != null && log!.stackTrace!.isNotEmpty)
          _logItem(
            'Stack Trace',
            pre(
              classes: 'text-xs text-muted-foreground bg-muted p-3 rounded-md overflow-x-auto max-h-64 overflow-y-auto',
              [
                Component.text(log!.stackTrace!),
              ],
            ),
          ),
      ]),
    ]);
  }

  Component _logItem(String label, Component value) {
    return div(classes: 'flex flex-col pb-4 border-b border-border', [
      span(classes: 'text-sm font-medium text-muted-foreground mb-1', [
        Component.text(label),
      ]),
      div(classes: 'text-sm text-foreground', [value]),
    ]);
  }
}
