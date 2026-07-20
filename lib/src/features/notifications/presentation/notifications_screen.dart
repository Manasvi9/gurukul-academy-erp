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
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            Text(
              'School announcements',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
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
                  message: 'Create a notification to communicate with the school.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: const CircleAvatar(
                          child: Icon(Icons.notifications_outlined),
                        ),
                        title: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        subtitle: Text(
                          item.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        trailing: Tooltip(
                          message: 'Archive',
                          child: IconButton(
                            onPressed: () => _archive(context, ref, item),
                            icon: const Icon(Icons.archive_outlined),
                          ),
                        ),
                      ),
                    );
                  },
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            item == null ? 'Create notification' : 'Edit notification',
          ),
          content: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Title is required.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Description is required.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.label_outlined),
                    ),
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
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: audience,
                    decoration: const InputDecoration(
                      labelText: 'Audience',
                      prefixIcon: Icon(Icons.groups_outlined),
                    ),
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
          ),
          actions: [
            OutlinedButton(
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
                        content: Text('Notification saved successfully ✅'),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text('Archive Notification'),
        content: const Text(
          'Are you sure you want to archive this notification?',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(notificationRepositoryProvider).archive(item.id);
    ref.invalidate(notificationsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification archived successfully. 📂'),
        ),
      );
    }
  }
}