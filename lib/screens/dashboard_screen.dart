import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback_entry.dart';
import '../providers/feedback_provider.dart';
import '../providers/field_config_provider.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gold_button.dart';
import '../widgets/tactical_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(feedbackProvider.notifier).fetchFeedbacks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      final entries = ref.read(feedbackProvider).valueOrNull ?? [];
      final fields = ref.read(fieldConfigProvider);
      await ExportService().exportToExcel(entries: entries, fields: fields);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 12),
                Text('Export failed: $e'),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(feedbackProvider.notifier).deleteFeedback(id);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppColors.crimson),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbacksAsync = ref.watch(feedbackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FEEDBACK LOG'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: feedbacksAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (e, _) => _buildErrorState(e.toString()),
              data: (entries) => _buildList(entries),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.12),
                                blurRadius: 10,
                                spreadRadius: 0.5,
                              ),
                            ]
                          : null,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search feedbacks...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.goldDark,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    size: 18, color: AppColors.textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          GoldButton(
            label: 'EXPORT',
            icon: Icons.file_download_outlined,
            isLoading: _isExporting,
            onPressed: _export,
            compact: true,
            width: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<FeedbackEntry> entries) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? entries
        : ref
            .read(feedbackProvider.notifier)
            .searchFeedbacks(query);

    if (filtered.isEmpty) {
      return _buildEmptyState(query.isNotEmpty);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return TacticalCard(
          entry: filtered[index],
          onDelete: () => _confirmDelete(filtered[index].id),
        ).animate().fadeIn(
              duration: 300.ms,
              delay: (index * 50).ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }

  Widget _buildEmptyState(bool isSearch) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearch ? Icons.search_off_rounded : Icons.inbox_rounded,
              size: 56,
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isSearch ? 'No matching feedbacks' : 'No feedback entries yet',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isSearch) ...[
              const SizedBox(height: 8),
              const Text(
                'Entries submitted from the Data Entry\nscreen will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: AppColors.gold.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connection Error',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            GoldButton(
              label: 'RETRY',
              icon: Icons.refresh,
              compact: true,
              width: 140,
              onPressed: () {
                ref.read(feedbackProvider.notifier).fetchFeedbacks();
              },
            ),
          ],
        ),
      ),
    );
  }
}
