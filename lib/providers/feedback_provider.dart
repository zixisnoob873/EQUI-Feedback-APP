import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feedback_entry.dart';
import '../services/supabase_service.dart';

class FeedbackNotifier extends StateNotifier<AsyncValue<List<FeedbackEntry>>> {
  final SupabaseService _supabase;

  FeedbackNotifier(this._supabase) : super(const AsyncValue.loading());

  Future<void> fetchFeedbacks() async {
    state = const AsyncValue.loading();
    try {
      final data = await _supabase.fetchFeedbacks();
      state = AsyncValue.data(
        data.map((json) => FeedbackEntry.fromJson(json)).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> submitFeedback(Map<String, dynamic> payload) async {
    try {
      await _supabase.submitFeedback(payload);
      await fetchFeedbacks();
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteFeedback(String id) async {
    try {
      await _supabase.deleteFeedback(id);
      await fetchFeedbacks();
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  List<FeedbackEntry> searchFeedbacks(String query) {
    final current = state.valueOrNull ?? [];
    if (query.isEmpty) return current;
    final lower = query.toLowerCase();
    return current.where((entry) {
      return entry.payload.values.any((value) {
        return value.toString().toLowerCase().contains(lower);
      });
    }).toList();
  }
}

final feedbackProvider =
    StateNotifierProvider<FeedbackNotifier, AsyncValue<List<FeedbackEntry>>>(
        (ref) {
  final supabase = SupabaseService();
  return FeedbackNotifier(supabase);
});
