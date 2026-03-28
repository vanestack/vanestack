import 'package:vanestack_client/vanestack_client.dart';
import 'package:vanestack_dashboard/components/menu_button.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../providers/client.dart';
import '../utils/toast.dart';

class HomePage extends StatefulComponent {
  @override
  State<StatefulComponent> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DashboardStats? _stats;
  bool _loading = true;
  bool _loadingStats = false;

  Future<void> _loadStats() async {
    if (_loadingStats) return;
    _loadingStats = true;

    try {
      final client = context.read(clientProvider);
      final stats = await client.stats.stats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showToast(category: ToastCategory.error, title: 'Failed to load stats');
    } finally {
      _loadingStats = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatNumber(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'flex flex-col flex-1 h-full overflow-hidden', [
      // Header
      div(
        classes: 'bg-card border-b border-border shrink-0 px-4 py-3 md:py-0 md:min-h-16 flex items-center',
        [
          MenuButton(classes: 'md:hidden mr-2'),
          h2(classes: 'text-2xl font-display font-bold', [Component.text('Dashboard')]),
        ],
      ),

      // Content
      div(classes: 'flex-1 overflow-y-auto p-4 md:p-6 space-y-6', [
        if (_loading)
          div(classes: 'flex items-center justify-center h-64', [
            div(classes: 'text-muted-foreground', [Component.text('Loading...')]),
          ])
        else if (_stats != null) ...[
          // Primary stat cards
          div(classes: 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4', [
            _statCard('Total Users', _formatNumber(_stats!.totalUsers), 'icon-users-round', 'text-blue-600',
                'bg-blue-500/10'),
            _statCard('Total Requests', _formatNumber(_stats!.totalRequests), 'icon-activity', 'text-emerald-600',
                'bg-emerald-500/10'),
            _statCard('Requests Today', _formatNumber(_stats!.requestsToday), 'icon-trending-up', 'text-purple-600',
                'bg-purple-500/10'),
            _statCard('Storage Used', _formatBytes(_stats!.totalStorageBytes), 'icon-hard-drive', 'text-amber-600',
                'bg-amber-500/10'),
          ]),

          // Secondary stats
          div(classes: 'grid grid-cols-1 sm:grid-cols-2 gap-4', [
            _statCard('Documents', _formatNumber(_stats!.totalDocuments), 'icon-database', 'text-indigo-600',
                'bg-indigo-500/10'),
            _statCard('Files', _formatNumber(_stats!.totalFiles), 'icon-file', 'text-teal-600', 'bg-teal-500/10'),
          ]),

          // Status breakdown
          if (_stats!.statusBreakdown.isNotEmpty)
            div(classes: 'bg-card border border-border rounded-xl p-6', [
              h3(classes: 'text-lg font-display font-semibold mb-4', [Component.text('Response Status Breakdown')]),
              div(classes: 'flex flex-wrap gap-3', [
                for (final entry in _stats!.statusBreakdown.entries)
                  _statusBadge(entry.key, entry.value),
              ]),
            ]),

          // Requests per day chart
          if (_stats!.requestsPerDay.isNotEmpty)
            div(classes: 'bg-card border border-border rounded-xl p-6', [
              h3(classes: 'text-lg font-display font-semibold mb-4', [Component.text('Requests (Last 7 Days)')]),
              _barChart(_stats!.requestsPerDay),
            ]),
        ],
      ]),
    ]);
  }

  Component _statCard(String label, String value, String iconClass, String iconColor, String iconBg) {
    return div(classes: 'bg-card border border-border rounded-xl p-6', [
      div(classes: 'flex items-center justify-between', [
        div([
          p(classes: 'text-sm font-medium text-muted-foreground', [Component.text(label)]),
          p(classes: 'text-3xl font-display font-bold mt-1', [Component.text(value)]),
        ]),
        div(
          classes: 'w-11 h-11 rounded-xl $iconBg flex items-center justify-center',
          [i(classes: '$iconClass $iconColor text-lg', [])],
        ),
      ]),
    ]);
  }

  Component _statusBadge(String status, int count) {
    final badgeClass = switch (status) {
      '2xx' => 'bg-emerald-100 text-emerald-700 border-emerald-200 dark:bg-emerald-500/10 dark:text-emerald-400 dark:border-emerald-500/20',
      '4xx' => 'bg-amber-100 text-amber-700 border-amber-200 dark:bg-amber-500/10 dark:text-amber-400 dark:border-amber-500/20',
      '5xx' => 'bg-red-100 text-red-700 border-red-200 dark:bg-red-500/10 dark:text-red-400 dark:border-red-500/20',
      _ => 'bg-muted text-muted-foreground border-border',
    };
    return span(
      classes: 'inline-flex items-center gap-2 px-4 py-2 rounded-lg border text-sm font-medium $badgeClass',
      [
        Component.text(status),
        span(classes: 'font-bold', [Component.text(_formatNumber(count))]),
      ],
    );
  }

  Component _barChart(List<RequestPoint> points) {
    final maxCount = points.fold<int>(0, (max, p) => p.count > max ? p.count : max);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return div(classes: 'flex items-end gap-3 h-44', [
      for (final point in points)
        div(classes: 'flex-1 flex flex-col items-center gap-1.5', [
          span(classes: 'text-xs font-medium text-muted-foreground', [Component.text('${point.count}')]),
          div(
            classes: 'w-full rounded-md min-h-1 bg-gradient-to-t from-blue-600 to-indigo-500 dark:from-blue-500 dark:to-indigo-400',
            attributes: {'style': 'height: ${maxCount > 0 ? (point.count / maxCount * 130).round() : 4}px'},
            [],
          ),
          span(classes: 'text-xs font-medium text-muted-foreground', [
            Component.text(dayNames[point.date.weekday - 1]),
          ]),
        ]),
    ]);
  }
}
