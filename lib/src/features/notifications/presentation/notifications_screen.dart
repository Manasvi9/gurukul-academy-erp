import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_async_view.dart';
import '../../../shared/widgets/app_empty_view.dart';
import '../../../shared/widgets/responsive_page.dart';
import '../domain/entities/app_notification.dart';
import 'notification_providers.dart';

final class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: ResponsivePage(
        maxWidth: 900,
        child: AppAsyncView(
          value: notices,
          data: (items) => items.isEmpty
              ? const AppEmptyView(
                  title: 'No notifications',
                  message:
                      'Create a notification to communicate with the school.',
                )
              : ListView(
                  children: items
                      .map(
                        (item) => ListTile(
                          title: Text(item.title),
                          subtitle: Text(item.description),
                          trailing: IconButton(
                            onPressed: () => _archive(context, ref, item),
                            icon: const Icon(Icons.archive_outlined),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ),
    );
  }

  Future<void> _form(
    BuildContext context,
    WidgetRef ref, [
    AppNotification? item,
  ]) async {
    final key = GlobalKey<FormState>();
    final title = TextEditingController(text: item?.title);
    final description = TextEditingController(text: item?.description);
    var type = item?.type ?? 'general';
    var audience = item?.audience ?? 'all';
    await showDialog<void>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            item == null ? 'Create notification' : 'Edit notification',
          ),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Title is required.'
                      : null,
                ),
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  minLines: 3,
                  maxLines: 5,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Description is required.'
                      : null,
                ),
                DropdownButtonFormField(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    'general',
                    'holiday',
                    'fee_reminder',
                    'homework',
                    'exam',
                    'emergency',
                  ]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => type = value!),
                ),
                DropdownButtonFormField(
                  initialValue: audience,
                  decoration: const InputDecoration(labelText: 'Audience'),
                  items: const [
                    'all',
                    'teachers',
                    'parents',
                    'students',
                  ]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => audience = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!key.currentState!.validate()) return;
                try {
                  await ref.read(notificationRepositoryProvider).save(
                        id: item?.id,
                        title: title.text,
                        description: description.text,
                        type: type,
                        audience: audience,
                        publishedOn: item?.publishedOn ?? DateTime.now(),
                        expiresOn: item?.expiresOn,
                      );
                  ref.invalidate(notificationsProvider);
                  if (dialog.mounted) {
                    Navigator.pop(dialog);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification saved.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    AppNotification item,
  ) async {
    await ref.read(notificationRepositoryProvider).archive(item.id);
    ref.invalidate(notificationsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification archived.')),
      );
    }
  }
}
