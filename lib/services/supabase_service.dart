import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://iiavhqirkquxmzhhatsg.supabase.co';
  static const String publishableKey =
      'sb_publishable_erIq4kFBKfdBlYDr5iySUw_BQ2eIgrt';
}

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  Future<List<Map<String, dynamic>>> fetchFeedbacks({
    int limit = 100,
    int page = 0,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;
    final response = await client
        .from('feedbacks')
        .select()
        .order('created_at', ascending: false)
        .range(from, to);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> submitFeedback(
      Map<String, dynamic> payload) async {
    final response = await client
        .from('feedbacks')
        .insert({'payload': payload})
        .select()
        .single();
    return response;
  }

  Future<void> deleteFeedback(String id) async {
    await client.from('feedbacks').delete().eq('id', id);
  }

  Future<int> getFeedbackCount() async {
    final response = await client
        .from('feedbacks')
        .select()
        .count(CountOption.exact);
    return response.count;
  }
}
