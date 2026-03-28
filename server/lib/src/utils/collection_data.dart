import 'package:vanestack_common/vanestack_common.dart';

import '../database/database.dart';

/// Extension to convert database rows (CollectionData) to Collection models
extension CollectionDataMapper on CollectionData {
  Collection toModel() {
    if (type == 'view') {
      return ViewCollection(
        name: name,
        attributes: attributes,
        listRule: listRule,
        viewRule: viewRule,
        viewQuery: viewQuery!,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }
    return BaseCollection(
      name: name,
      attributes: attributes,
      indexes: indexes,
      listRule: listRule,
      viewRule: viewRule,
      createRule: createRule,
      updateRule: updateRule,
      deleteRule: deleteRule,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
