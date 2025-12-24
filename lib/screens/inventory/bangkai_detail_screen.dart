import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/bangkai_provider.dart';
import '../../data/models/bangkai.dart';

/// BangkaiDetailScreen - Detail item inventaris
class BangkaiDetailScreen extends ConsumerWidget {
  final String bangkaiId;
  
  const BangkaiDetailScreen({
    super.key,
    required this.bangkaiId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(inventoryNoteListProvider);
    final note = notes.firstWhere(
      (n) => n.id == bangkaiId,
      orElse: () => InventoryNote(
        id: '',
        title: '',
        createdAt: DateTime.now(),
      ),
    );
    
    if (note.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item tidak ditemukan')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Item'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, ref, note),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (note.hasImage)
              Container(
                width: double.infinity,
                height: 250,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Image.file(
                  File(note.imagePath!),
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 150,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note.title,
                    style: AppTypography.headingMD.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  
                  const Gap(8),
                  
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const Gap(4),
                      Text(
                        'Ditambahkan ${note.formattedDate}',
                        style: AppTypography.bodySM.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  
                  if (note.description != null && note.description!.isNotEmpty) ...[
                    const Gap(20),
                    const Divider(),
                    const Gap(12),
                    
                    // Description Label
                    Text(
                      'Deskripsi',
                      style: AppTypography.labelMD.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const Gap(8),
                    
                    // Description Content
                    Text(
                      note.description!,
                      style: AppTypography.bodyMD.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, InventoryNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: Text('Apakah Anda yakin ingin menghapus "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(inventoryNoteListProvider.notifier).deleteNote(note.id);
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item dihapus')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
