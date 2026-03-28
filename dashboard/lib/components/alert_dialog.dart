import 'package:vanestack_client/vanestack_client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';

import '../utils/toast.dart';

class AlertDialog extends StatefulComponent {
  final String id;
  final Component title;
  final Component? description;
  final Component? content;
  final Component Function(bool saving) button;

  final Future<bool> Function()? onSubmit;

  const AlertDialog({
    super.key,
    required this.id,
    required this.title,
    this.description,
    this.content,
    required this.button,
    this.onSubmit,
  });

  @override
  AlertDialogState createState() => AlertDialogState();
}

class AlertDialogState extends State<AlertDialog> {
  final _saving = ValueNotifier(false);

  void close() {
    final modal = document.getElementById(component.id) as HTMLDialogElement;
    modal.close();
  }

  Future<void> save() async {
    _saving.value = true;
    try {
      final shouldClose = await component.onSubmit?.call();
      _saving.value = false;
      if (shouldClose == false) {
        return;
      }
      close();
    } on VaneStackException catch (e) {
      _saving.value = false;

      showToast(
        category: ToastCategory.error,
        title: 'Something went wrong',
        description: e.message,
      );
    }
  }

  @override
  Component build(BuildContext context) {
    return dialog(
      id: component.id,
      classes: 'dialog',
      attributes: {
        'aria-labelledby': 'alert-dialog-title',
        if (component.description != null) 'aria-describedby': 'alert-dialog-description',
      },
      [
        div([
          header([
            h2(id: 'alert-dialog-title', [component.title]),
            if (component.description != null) p(id: 'alert-dialog-description', [component.description!]),
          ]),
          if (component.content != null) section([component.content!]),
          footer([
            button(classes: 'btn-outline', onClick: close, [Component.text('Cancel')]),
            ValueListenableBuilder(
              listenable: _saving,
              builder: (context, saving) => button(
                disabled: saving,
                classes: 'btn-primary',
                onClick: save,
                [component.button(saving)],
              ),
            ),
          ]),
        ]),
      ],
    );
  }
}
