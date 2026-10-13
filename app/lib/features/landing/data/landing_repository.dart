import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/supabase_providers.dart';
import '../../sizing/domain/sizing_config.dart';

part 'landing_repository.g.dart';

class NewsItem {
  const NewsItem({
    required this.title,
    required this.url,
    this.source,
    this.publishedAt,
  });

  final String title;
  final String url;
  final String? source;
  final DateTime? publishedAt;
}

/// Public data for the landing page (no login): the platform's default
/// sizing settings and the daily news headlines.
class LandingRepository {
  LandingRepository(this._client);

  final SupabaseClient _client;

  Future<SizingConfig> sizingDefaults() async {
    List<Map<String, Object?>> rows(List<dynamic> d) => [
      for (final r in d) (r as Map).cast<String, Object?>(),
    ];
    final results = await Future.wait([
      _client.from('app_config').select().isFilter('company_id', null),
      _client.from('subsidy_rules').select().isFilter('company_id', null),
      _client.from('tariffs').select().isFilter('company_id', null),
      _client.from('loan_presets').select().isFilter('company_id', null),
    ]);
    return SizingConfig.fromRows(
      companyId: '',
      appConfig: rows(results[0]),
      subsidyRules: rows(results[1]),
      tariffs: rows(results[2]),
      loanPresets: rows(results[3]),
    );
  }

  Future<List<NewsItem>> latestNews(String lang, {int limit = 9}) async {
    final data = await _client
        .from('news_items')
        .select('title, url, source, published_at')
        .eq('lang', lang)
        .order('published_at', ascending: false)
        .limit(limit);
    return [
      for (final r in data)
        NewsItem(
          title: r['title'] as String,
          url: r['url'] as String,
          source: r['source'] as String?,
          publishedAt: DateTime.tryParse((r['published_at'] as String?) ?? ''),
        ),
    ];
  }
}

@Riverpod(keepAlive: true)
LandingRepository landingRepository(Ref ref) =>
    LandingRepository(ref.watch(supabaseClientProvider));

@riverpod
Future<SizingConfig> publicSizingConfig(Ref ref) =>
    ref.watch(landingRepositoryProvider).sizingDefaults();

@riverpod
Future<List<NewsItem>> latestNews(Ref ref, String lang) =>
    ref.watch(landingRepositoryProvider).latestNews(lang);
