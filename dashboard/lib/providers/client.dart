import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:vanestack_client/vanestack_client.dart';

final clientProvider = Provider<VaneStackClient>(
  (ref) => throw UnimplementedError('clientProvider must be overridden in the provider scope'),
);
