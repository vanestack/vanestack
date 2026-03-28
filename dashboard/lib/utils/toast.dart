import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

enum ToastCategory { success, error, info, warning }

void showToast({
  int? durationInMilliseconds,
  ToastCategory? category,
  required String title,
  String? description,
  String? cancelLabel,
  String? actionLabel,
}) => document.dispatchEvent(
  CustomEvent(
    'basecoat:toast',
    CustomEventInit(
      detail: {
        "config": {
          if (durationInMilliseconds != null)
            "duration": durationInMilliseconds,
          if (category != null) "category": category.name,
          "title": title,
          "description": description,
          if (cancelLabel != null) "cancel": {"label": cancelLabel},
          if (actionLabel != null) "action": {"label": actionLabel},
        },
      }.jsify(),
    ),
  ),
);
